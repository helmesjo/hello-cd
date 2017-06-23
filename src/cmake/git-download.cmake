find_package(Git REQUIRED)

function(execute_git)
    set(options "")
    set(oneValueArgs
        OUTPUT_VARIABLE
    )
    set(multiValueArgs
        COMMAND
    )
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    execute_process(
        COMMAND ${GIT_EXECUTABLE} ${args_COMMAND}
        OUTPUT_VARIABLE GIT_RESULT
    )

    set(${args_OUTPUT_VARIABLE} ${GIT_RESULT} PARENT_SCOPE)
endfunction()

function(download_repo)
    set(options "")
    set(oneValueArgs
        URL
        TAG
        CLONE_DIR
    )
    set(multiValueArgs "")
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Determine if there are local changes, then we need to stash save & pop
    execute_git(
        COMMAND diff --shortstat
        OUTPUT_VARIABLE GIT_HAVE_CHANGES
    )

    if(GIT_HAVE_CHANGES)
        message(AUTHOR_WARNING "Local changes detected, skipping download.\n\tGit subtree requires a clean directory; please commit changes before running this.")
        return()
    endif()

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

    message("Cloning branch ${args_TAG} from ${args_URL} into relative directory ${RELATIVE_CLONE_DIR}:")
    set(MERGE_MESSAGE "Merged branch ${args_TAG} in repository ${args_URL}.")
    if(NOT EXISTS ${args_CLONE_DIR})
        message("\tAdding...")
        execute_git(
            COMMAND subtree add --prefix ${RELATIVE_CLONE_DIR} ${args_URL} ${args_TAG} --squash --message ${MERGE_MESSAGE}
            WORKING_DIRECTORY ${GIT_ROOT}
        )
    else()
        message("\tUpdating...")
        execute_git(
            COMMAND subtree pull --prefix ${RELATIVE_CLONE_DIR} ${args_URL} ${args_TAG} --squash --message ${MERGE_MESSAGE}
            WORKING_DIRECTORY ${GIT_ROOT}
        )
    endif()

endfunction()