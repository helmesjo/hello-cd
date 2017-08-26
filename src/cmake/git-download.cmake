find_package(Git REQUIRED)

function(execute_git)
    set(options "")
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

    execute_process(
        COMMAND ${GIT_EXECUTABLE} ${args_COMMAND}
        OUTPUT_VARIABLE GIT_RESULT
        WORKING_DIRECTORY ${args_WORKING_DIRECTORY}
    )

    set(${args_OUTPUT_VARIABLE} ${GIT_RESULT} PARENT_SCOPE)
endfunction()

function(get_repo_head)
    set(oneValueArgs
        URL
        TAG
        OUTPUT_VARIABLE
    )
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Get remote HEAD for tag (need some parsing)
    execute_git(
        COMMAND ls-remote ${args_URL} ${args_TAG}
        OUTPUT_VARIABLE REMOTE_HEAD
    )
    string(REGEX REPLACE "\t" ";" REMOTE_HEAD ${REMOTE_HEAD})
    list (GET REMOTE_HEAD 0 REMOTE_HEAD)

    set(${args_OUTPUT_VARIABLE} ${REMOTE_HEAD} PARENT_SCOPE)
endfunction()

function(check_if_up_to_date)
    set(oneValueArgs
        URL
        TAG
        CLONE_DIR
        OUTPUT_VARIABLE
    )
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(${args_OUTPUT_VARIABLE} "FALSE" PARENT_SCOPE)
    
    get_repo_head(
        ${ARGV}
        OUTPUT_VARIABLE REMOTE_HEAD
    )
    
    # If there is a meta file, and the remote HEAD matches local stored in file, we are up-to-date
    set(META_PATH "${args_CLONE_DIR}_meta")
    if(EXISTS "${META_PATH}")
        file(READ "${META_PATH}" CURRENT_HEAD)
    else()
        return()
    endif()

    if(${CURRENT_HEAD} STREQUAL ${REMOTE_HEAD})
        set(${args_OUTPUT_VARIABLE} "TRUE" PARENT_SCOPE)
    endif()
endfunction()

function(store_repo_head)
    set(oneValueArgs
        URL
        TAG
        CLONE_DIR
    )
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    get_repo_head(
        ${ARGV}
        OUTPUT_VARIABLE REMOTE_HEAD
    )
    set(META_PATH "${args_CLONE_DIR}_meta")
    file(
        WRITE "${META_PATH}" "${REMOTE_HEAD}"
    )
endfunction()

function(download_repo)
    set(options "")
    set(oneValueArgs
        URL
        TAG
        CLONE_DIR
        SUBMODULES
    )
    set(multiValueArgs "")
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # If no tag is specified, default to master
    if(NOT args_TAG)
        set(args_TAG master)
    endif()

    execute_git(
        COMMAND rev-parse --show-toplevel
        OUTPUT_VARIABLE GIT_ROOT
    )
    # Need to remove linebreak
    string(STRIP ${GIT_ROOT} GIT_ROOT)

    # Make clone-dir path relative to git-root
    string(REPLACE ${GIT_ROOT}/ "" RELATIVE_CLONE_DIR ${args_CLONE_DIR})

    message("Cloning branch ${args_TAG} from ${args_URL} into relative directory ${RELATIVE_CLONE_DIR}...")
    
    # Determine if there are local changes, in which case download will be skipped
    execute_git(
        COMMAND diff --shortstat
        OUTPUT_VARIABLE GIT_HAVE_CHANGES
    )
    if(GIT_HAVE_CHANGES)
        message(WARNING "Local changes detected, skipping download.\n\tGit subtree requires a clean directory; please commit changes before running this.\n\t${GIT_HAVE_CHANGES}")
        #return()
    endif()

    # Compare HEAD on remote URL:TAG with local (if any), skip download if up-to-date
    check_if_up_to_date(
        ${ARGV}
        OUTPUT_VARIABLE IS_UP_TO_DATE
    )
    if(IS_UP_TO_DATE)
        message("Already up-to-date with tag '${args_TAG}' on ${args_URL}\n\tSkipping download...")
        return()
    endif()

    # Submodules can't be pulled with git subtree, so in this case clone 
    # normally to temp-dir, download specified submodules and set git-url to this instead of remote.
    # Note: Must
    if(args_SUBMODULES)
        set(TMP_DIR "${CMAKE_BINARY_DIR}/tmp")
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E remove_directory ${TMP_DIR}
            WORKING_DIRECTORY "${TMP_DIR}/.."
        )

        execute_git(
            COMMAND clone ${args_URL} "${TMP_DIR}"
        )
        execute_process(
            COMMAND ${GIT_EXECUTABLE} checkout ${args_TAG}
            WORKING_DIRECTORY "${TMP_DIR}"
        )
        execute_process(
            COMMAND ${GIT_EXECUTABLE} submodule update --init ${args_SUBMODULES}
            WORKING_DIRECTORY "${TMP_DIR}"
        )

        execute_git(
            COMMAND rm .gitmodules
            WORKING_DIRECTORY "${TMP_DIR}"
        )

        # Merge submodules into main repo so that subtree merges it all
        foreach(SUBMODULE ${args_SUBMODULES})
            execute_git(
                COMMAND rm --cached ${SUBMODULE}
                WORKING_DIRECTORY "${TMP_DIR}"
            )
            execute_process(
                COMMAND ${CMAKE_COMMAND} -E remove ${SUBMODULE}/.git
                WORKING_DIRECTORY "${TMP_DIR}"
            )
        endforeach()
        
        execute_git(
            COMMAND add -A
            WORKING_DIRECTORY "${TMP_DIR}"
        )
        execute_git(
            COMMAND commit -am "git-download: Merged submodules into main repo for use with subtree."
            WORKING_DIRECTORY "${TMP_DIR}"
        )

        set(args_URL "${TMP_DIR}/.git")
        
    endif()

    set(MERGE_MESSAGE "Merged branch ${args_TAG} in repository ${args_URL}.")
    if(NOT EXISTS ${args_CLONE_DIR})
        message("\tAdding...")
        execute_git(
            COMMAND subtree add --prefix ${RELATIVE_CLONE_DIR} ${args_URL} ${args_TAG} --squash --message ${MERGE_MESSAGE}
            WORKING_DIRECTORY ${GIT_ROOT}
        )
    else()
        message("\tChecking for updates...")
        execute_git(
            COMMAND subtree pull --prefix ${RELATIVE_CLONE_DIR} ${args_URL} ${args_TAG} --squash --message ${MERGE_MESSAGE}
            WORKING_DIRECTORY ${GIT_ROOT}
        )
    endif()

    # Assuming everything went well, remember HEAD to compare each future runs
    store_repo_head(
        ${ARGV}
    )

endfunction()