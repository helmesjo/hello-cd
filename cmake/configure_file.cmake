# If variables are defined, persume we are in script mode ('cmake -P configure_file.cmake')
if(ARG_FILE_IN AND ARG_FILE_OUT)
    configure_file(${ARG_FILE_IN} ${ARG_FILE_OUT})
endif()

set(THIS_FILE_PATH "${CMAKE_CURRENT_LIST_FILE}")

function(configure_file_buildtime)
    set(oneValueArgs
        FILE_IN
        FILE_OUT
    )
    set(multiValueArgs
        VARIABLES
    )
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Add -D prefix to all variables (will be passed as arguments to command)
    string(REPLACE ";" ";-D" arg_VARIABLES "${arg_VARIABLES}")
    set(arg_VARIABLES "-D${arg_VARIABLES}")

    add_custom_command(
        OUTPUT "${arg_FILE_OUT}"
        COMMAND 
            ${CMAKE_COMMAND}
                ${arg_VARIABLES}
                -DARG_FILE_IN="${arg_FILE_IN}"
                -DARG_FILE_OUT="${arg_FILE_OUT}" 
                -P "${THIS_FILE_PATH}"
        DEPENDS "${arg_FILE_IN}"
        COMMENT "Configuring file ${arg_FILE_IN}"
    )

endfunction()