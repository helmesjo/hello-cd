find_package(Git REQUIRED)

if(WIN32)
    set(BOOTSTRAP_SCRIPT "bootstrap.bat")
else()
    set(BOOTSTRAP_SCRIPT "bootstrap.sh")
endif()

set(BUILD_SCRIPT "b2")
set(BOOSTDEP_EXEC_PATH "dist/bin/boostdep")

function(execute_git)
    set(oneValueArgs
        WORKING_DIRECTORY
        OUTPUT_VARIABLE
    )
    set(multiValueArgs
        COMMAND
    )
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT args_WORKING_DIRECTORY)
        set(args_WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")
    endif()

    message("Running git-command: git ${args_COMMAND}")

    execute_process(
        COMMAND ${GIT_EXECUTABLE} ${args_COMMAND}
        OUTPUT_VARIABLE GIT_RESULT
        RESULT_VARIABLE RETURN_CODE
        WORKING_DIRECTORY ${args_WORKING_DIRECTORY}
    )

    if(NOT "${RETURN_CODE}" STREQUAL "0")
        message(FATAL_ERROR "Failed to run 'git ${args_COMMAND}'")
    endif()

    set(${args_OUTPUT_VARIABLE} ${GIT_RESULT} PARENT_SCOPE)
endfunction()

function(clone_repo)
    set(oneValueArgs
        URL
        TAG
        CLONE_DIR
    )
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT EXISTS "${args_CLONE_DIR}")
        execute_git(
            COMMAND clone --depth=1 --single-branch --branch ${args_TAG} ${args_URL} "${args_CLONE_DIR}"
        )
        # Fix for issues with long paths
        execute_git(
            COMMAND config core.longpaths true
            WORKING_DIRECTORY ${args_CLONE_DIR}
        )
    else()
    # what to do here? Safest is to download again... Or clear changes and pull
        return()
        execute_git(
            COMMAND pull -b ${args_TAG} --single-branch ${args_URL} "${args_CLONE_DIR}"
            WORKING_DIRECTORY "${args_CLONE_DIR}"
        )
    endif()
endfunction()

function(pull_modules)
    set(oneValueArgs
        REPO_DIR
    )
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    execute_git(
        COMMAND submodule update --depth=1 --init
        WORKING_DIRECTORY "${args_REPO_DIR}"
    )

endfunction()

function(get_required_modules)
    set(oneValueArgs
        REPO_DIR
        OPTIONAL 
            ALL_MODULES
            REQUIRED_MODULES
            UNUSED_MODULES
    )
    set(multiValueArgs
        SUBMODULES
    )
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(ALL_REQUIRED_MODULES "")
    # Run through each module and find required dependencies
    foreach(MODULE ${args_SUBMODULES})
        #message("Finding required dependencies for ${MODULE}...")
        execute_process(
            COMMAND ${BOOSTDEP_EXEC_PATH} --subset ${MODULE}
            OUTPUT_VARIABLE REQUIRED_MODULES
            WORKING_DIRECTORY ${args_REPO_DIR}
        )

        # Pattern-match to find module-name (eg. "assert:"), then remove ":"
        string(REGEX MATCHALL "[a-z_]*:" REQUIRED_MODULES "${REQUIRED_MODULES}")
        string(REPLACE ":" "" REQUIRED_MODULES "${REQUIRED_MODULES}")

        # Only add unique and missing modules
        foreach(DEPENDENCY ${REQUIRED_MODULES})
            if(NOT DEPENDENCY IN_LIST ALL_REQUIRED_MODULES)
                list(APPEND ALL_REQUIRED_MODULES ${DEPENDENCY})
            endif()
        endforeach()

        message("Required modules for ${MODULE}: ${REQUIRED_MODULES}\n")
    endforeach()
    
    # List all modules
    execute_process(
        COMMAND ${BOOSTDEP_EXEC_PATH} --list-modules
        OUTPUT_VARIABLE ALL_MODULES
        WORKING_DIRECTORY ${args_REPO_DIR}
    )
    # Convert to list
    string(REPLACE "\n" ";" ALL_MODULES "${ALL_MODULES}")
    # Determine which modules are unused
    set(ALL_UNUSED_MODULES "")
    foreach(MODULE ${ALL_MODULES})
        if(NOT MODULE IN_LIST ALL_REQUIRED_MODULES)
            list(APPEND ALL_UNUSED_MODULES ${MODULE})
        endif()
    endforeach()

    set(${args_ALL_MODULES} ${ALL_MODULES} PARENT_SCOPE)
    set(${args_REQUIRED_MODULES} ${ALL_REQUIRED_MODULES} PARENT_SCOPE)
    set(${args_UNUSED_MODULES} ${ALL_UNUSED_MODULES} PARENT_SCOPE)
endfunction()


function(download_boost)
    set(oneValueArgs
        URL
        TAG
        CLONE_DIR
    )
    set(multiValueArgs
        SUBMODULES
    )
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT EXISTS "${args_CLONE_DIR}")
        # 1: Clone repo
        clone_repo(
            ${ARGV}
        )
        # 2: Pull all modules
        pull_modules(
            REPO_DIR ${args_CLONE_DIR}
        )
    endif()

    file( GLOB IS_B2_BUILT "${args_CLONE_DIR}/b2*" )
    if(NOT IS_B2_BUILT)
        # 3: Run boostrap
        execute_process(
            COMMAND ${BOOTSTRAP_SCRIPT}
            WORKING_DIRECTORY ${args_CLONE_DIR}
        )
    endif()

    if(NOT EXISTS "${args_CLONE_DIR}/${BOOSTDEP_EXEC_PATH}")
        # 4: Build (and install) boostdep. Will be put in dist/bin/
        execute_process(
            COMMAND ${BUILD_SCRIPT} "tools/boostdep/build//install"
            WORKING_DIRECTORY ${args_CLONE_DIR}
        )
    endif()

    # 6: Get missing dependencies for all modules
    get_required_modules(
        REPO_DIR ${args_CLONE_DIR}
        SUBMODULES ${args_SUBMODULES}
        REQUIRED_MODULES MODULES_NEEDED
        UNUSED_MODULES MODULES_TO_REMOVE
    )

    foreach(MODULE ${MODULES_TO_REMOVE})
        if(NOT MODULE IN_LIST MODULES_NEEDED)
            file(REMOVE_RECURSE "${args_CLONE_DIR}/libs/${MODULE}")
        endif()
    endforeach()
    
    message("All required modules: ${MODULES_NEEDED}\n")
    message("All unused modules (removed): ${MODULES_TO_REMOVE}\n")

endfunction()


# Needed submodules to build boostdep:
# * tools/build
# * tools/boostdep
# * libs/config
# * libs/filesystem
# * libs/system
# * libs/core
# * libs/type_traits
# * libs/predef
# * libs/assert
# * libs/iterator
# * libs/mpl
# * libs/preprocessor
# * libs/static_assert
# * libs/detail
# * libs/smart_ptr
# * libs/throw_exception
# * libs/io
# * libs/functional
# * libs/range
# * libs/winapi (if on windows)