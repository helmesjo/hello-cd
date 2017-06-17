find_package(git REQUIRED)

function(download_repo)
    set(options "")
    set(oneValueArgs
        DO_PULL
        URL
        TAG
        CLONE_DIR
    )
    set(multiValueArgs "")
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT EXISTS ${args_CLONE_DIR})
        message("Cloning repository ${args_URL}...")
        execute_process(
            COMMAND ${GIT_EXECUTABLE} clone ${args_URL} ${args_CLONE_DIR}
        )
    endif()

    if(args_DO_PULL)
        message("Pulling latest changes...")
        execute_process(
            COMMAND ${GIT_EXECUTABLE} pull
            WORKING_DIRECTORY ${args_CLONE_DIR}
            TIMEOUT 30
        )
    endif()

    if(args_TAG)
        message("Checking out tag ${args_TAG}...")
        execute_process(
            COMMAND ${GIT_EXECUTABLE} checkout ${args_TAG}
            WORKING_DIRECTORY ${args_CLONE_DIR}
        )
    endif()

endfunction()