find_package(Git REQUIRED)

if(WIN32)
    set(BOOTSTRAP_SCRIPT "bootstrap.bat")
else()
    set(BOOTSTRAP_SCRIPT "bootstrap.sh")
endif()

set(BUILD_SCRIPT "b2")
set(BCP_EXEC_PATH "dist/bin/bcp")

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
        ERROR_VARIABLE GIT_ERROR
        RESULT_VARIABLE RETURN_CODE
        WORKING_DIRECTORY ${args_WORKING_DIRECTORY}
    )

    if(NOT "${RETURN_CODE}" STREQUAL "0")
        message(FATAL_ERROR "Failed to run 'git ${args_COMMAND}' :\n\t${GIT_ERROR}")
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
            COMMAND config --system core.longpaths true
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
        BOOST_DIR
    )
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    execute_git(
        COMMAND submodule update --depth=1 --init
        WORKING_DIRECTORY "${args_BOOST_DIR}"
    )

endfunction()

function(copy_required_modules)
    set(oneValueArgs
        BOOST_DIR
        OUTPUT_DIR
    )
    set(multiValueArgs
        SUBMODULES
    )
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    file(MAKE_DIRECTORY "${args_OUTPUT_DIR}")
    message("Copying subset of boost required for modules: ${args_SUBMODULES}\n\tTo folder: ${args_OUTPUT_DIR}")
    execute_process(
        COMMAND "${BCP_EXEC_PATH}" ${args_SUBMODULES} "${args_OUTPUT_DIR}"
        WORKING_DIRECTORY "${args_BOOST_DIR}"
    )

endfunction()

function(remove_non_source)
    set(oneValueArgs
        BOOST_DIR
    )
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    message("Removing non-source files from all libraries, including docs, examples & tests.")
    
    file(GLOB NON_SOURCE_DIRS
        ABSOLUTE "${args_BOOST_DIR}/" 
            "${args_BOOST_DIR}/libs/*/doc/"
            "${args_BOOST_DIR}/libs/*/example/"
            "${args_BOOST_DIR}/libs/*/test/"
            "${args_BOOST_DIR}/tools/*/doc/"
            "${args_BOOST_DIR}/tools/*/example/"
            "${args_BOOST_DIR}/tools/*/test/"
    )

    foreach(DIR ${NON_SOURCE_DIRS})
        file(REMOVE_RECURSE "${DIR}")
        file(RELATIVE_PATH REL_DIR "${args_BOOST_DIR}" "${DIR}")
        message("Removed: ${REL_DIR}.")
    endforeach()

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

    file(REMOVE_RECURSE "${args_CLONE_DIR}")
    set(TMP_DIR "${args_CLONE_DIR}/boost-download_tmp")
    
    # Clone repo
    clone_repo(
        URL ${args_URL}
        TAG ${args_TAG}
        CLONE_DIR "${TMP_DIR}"
    )
    # Pull all modules
    pull_modules(
        BOOST_DIR "${TMP_DIR}"
    )

    # Remove crap
    remove_non_source(
        BOOST_DIR "${TMP_DIR}"
    )

    # Run bootstrap
    file( GLOB IS_B2_BUILT "${TMP_DIR}/b2*" )
    if(NOT IS_B2_BUILT)
        execute_process(
            COMMAND ${BOOTSTRAP_SCRIPT}
            WORKING_DIRECTORY "${TMP_DIR}"
        )
    endif()

    # Generate header sym-links
    execute_process(
        COMMAND ${BUILD_SCRIPT} "headers"
        WORKING_DIRECTORY "${TMP_DIR}"
    )

    # Build bcp. Will be put in dist/bin/
    if(NOT EXISTS "${TMP_DIR}/${BCP_EXEC_PATH}*")
        execute_process(
            COMMAND ${BUILD_SCRIPT} "tools/bcp"
            WORKING_DIRECTORY "${TMP_DIR}"
        )
    endif()

    # Copy minimum required subset of boost to new dir
    copy_required_modules(
        BOOST_DIR ${TMP_DIR}
        SUBMODULES ${args_SUBMODULES}
        OUTPUT_DIR "${args_CLONE_DIR}"
    )

    # Clean up tmp-repo and remove (can't remove with all symlinks in ./boost/...)
    execute_git(
        COMMAND clean --force -d -x
        WORKING_DIRECTORY "${TMP_DIR}"
    )
    file(REMOVE_RECURSE "${TMP_DIR}")

    # Init new git repo which contains the minimal subset
    execute_git(
        COMMAND init
        WORKING_DIRECTORY "${args_CLONE_DIR}"
    )
    execute_git(
        COMMAND add -A
        WORKING_DIRECTORY "${args_CLONE_DIR}"
    )
    execute_git(
        COMMAND commit -am "Minimal boost"
        WORKING_DIRECTORY "${args_CLONE_DIR}"
    )
    execute_git(
        COMMAND tag ${args_TAG}
        WORKING_DIRECTORY "${args_CLONE_DIR}"
    )

    message("A minimal version containing required modules for: \n\t'${args_SUBMODULES}' \nhas been created at: \n\t${args_CLONE_DIR}")

endfunction()