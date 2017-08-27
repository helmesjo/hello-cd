find_package(Git REQUIRED)

# Required modules to build boostdep, which is used to determine when all other dependencies are satisfied
set(REQUIRED_MODULES 
    build 
    boostdep 
    chrono
    config 
    filesystem 
    system 
    core 
    type_traits 
    predef 
    assert 
    iterator 
    mpl 
    preprocessor 
    static_assert 
    detail
    smart_ptr
    throw_exception
    io
    functional
    range
)

if(WIN32)
    list(APPEND REQUIRED_MODULES winapi)
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
        message(FATAL_ERROR "Failed to run git command.")
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
    set(multiValueArgs
        SUBMODULES
    )
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Determine correct relative path to each module
    set(git_SUBMODULES "")
    foreach(boost_MODULE ${args_SUBMODULES})
        if(EXISTS "${args_REPO_DIR}/libs/${boost_MODULE}")
            list(APPEND git_SUBMODULES libs/${boost_MODULE})
        elseif(EXISTS "${args_REPO_DIR}/tools/${boost_MODULE}")
            list(APPEND git_SUBMODULES tools/${boost_MODULE})
        else()
            message(WARNING "Module '${boost_MODULE}' not found in either libs/ or tools/")
        endif()
    endforeach()

    execute_git(
        COMMAND submodule update --depth=1 --init ${git_SUBMODULES}
        WORKING_DIRECTORY "${args_REPO_DIR}"
    )
endfunction()

function(get_missing_dependencies)
    set(oneValueArgs
        REPO_DIR
        MISSING_DEPENDENCIES
    )
    set(multiValueArgs
        SUBMODULES
    )
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(ALL_MISSING_DEPENDENCIES "")
    # Run through each module and find missing dependencies
    foreach(MODULE ${args_SUBMODULES})
        message("Finding required dependencies for ${MODULE}...")
        execute_process(
            COMMAND ${BOOSTDEP_EXEC_PATH} --subset ${MODULE}
            OUTPUT_VARIABLE MISSING_DEPENDENCIES
            WORKING_DIRECTORY ${args_REPO_DIR}
        )

        # Pattern-match to find module-name (eg. "assert:"), then remove ":"
        string(REGEX MATCHALL "[a-z_]*:" MISSING_DEPENDENCIES "${MISSING_DEPENDENCIES}")
        string(REPLACE ":" "" MISSING_DEPENDENCIES "${MISSING_DEPENDENCIES}")

        # Only add unique and missing modules
        foreach(DEPENDENCY ${MISSING_DEPENDENCIES})
            if(NOT DEPENDENCY IN_LIST ALL_MISSING_DEPENDENCIES AND NOT EXISTS "${args_REPO_DIR}/libs/${DEPENDENCY}/.git")
                list(APPEND ALL_MISSING_DEPENDENCIES "${DEPENDENCY}")
            endif()
        endforeach()

        message("Required dependencies for ${MODULE}: ${MISSING_DEPENDENCIES}")
    endforeach()
    
    #message("All missing dependencies: \n${ALL_MISSING_DEPENDENCIES}")

    set(${args_MISSING_DEPENDENCIES} ${ALL_MISSING_DEPENDENCIES} PARENT_SCOPE)
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

    # 1: Clone repo
    clone_repo(
        ${ARGV}
    )
    # 2: Pull required modules for boostdep
    pull_modules(
        REPO_DIR ${args_CLONE_DIR}
        SUBMODULES ${REQUIRED_MODULES}
    )

    file( GLOB IS_BUILT "${args_CLONE_DIR}/b2*" )
    if(NOT IS_BUILT)
        # 3: Run boostrap
        execute_process(
            COMMAND ${BOOTSTRAP_SCRIPT}
            WORKING_DIRECTORY ${args_CLONE_DIR}
        )
        # 4: Build (and install) boostdep. Will be put in dist/bin/
        execute_process(
            COMMAND ${BUILD_SCRIPT} "tools/boostdep/build//install"
            WORKING_DIRECTORY ${args_CLONE_DIR}
        )
    endif()

    SET(MODULES_TO_PULL ${args_SUBMODULES})
    while(MODULES_TO_PULL)

        # 5: Pull specified modules
        pull_modules(
            REPO_DIR ${args_CLONE_DIR}
            SUBMODULES ${MODULES_TO_PULL}
        )
        # 6: Get missing dependencies for all modules
        get_missing_dependencies(
            REPO_DIR ${args_CLONE_DIR}
            SUBMODULES ${MODULES_TO_PULL}
            MISSING_DEPENDENCIES MODULES_TO_PULL
        )

        message("Modules still missing: ${MODULES_TO_PULL}")

    # 7: Repeat 6 until no missing dependencies
    endwhile()

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