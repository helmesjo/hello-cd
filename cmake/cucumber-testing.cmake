# If variables are defined, persume we are in script mode ('cmake -P this_file.cmake TEST_TARGET_PATH')
if(CUCUMBER_PATH AND TEST_TARGET_PATH AND TEST_FEATURE_PATH)
    execute_process(
        COMMAND ${TEST_TARGET_PATH}
        COMMAND ${CUCUMBER_PATH} --strict ${TEST_FEATURE_PATH}
        OUTPUT_VARIABLE OUT
        ERROR_VARIABLE ERROR
        RESULT_VARIABLE RESULT
    )

    if(RESULT)
        message(FATAL_ERROR "Return code: ${RESULT}\nError: ${ERROR}\nOutput: ${OUT}")
    endif()

    return()
endif()

find_program(CUCUMBER cucumber)

set(cucumber_testing_path "${CMAKE_CURRENT_LIST_FILE}")

if(NOT CUCUMBER)
    message("TESTING - Cucumber not found, skipping acceptance tests.")
    set(SKIP true)
elseif(WIN32)
    # CTest fails to run ruby gems directly, but works using the .bat equivalent
    set(CUCUMBER "${CUCUMBER}.bat")
endif()

set(PATH_TO_THIS ${CMAKE_CURRENT_LIST_FILE})
function(add_cucumber_test)
    if(SKIP)
        return()
    endif()

    set(oneValueArgs
        FEATURE
        FEATURES_ROOT
    )
    set(options "")
    set(multiValueArgs
        INCLUDE_DIRS
        SOURCES
        LINK_TARGETS
    )
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    get_filename_component(FEATURE_NAME ${arg_FEATURE} NAME_WE)

    add_executable( ${FEATURE_NAME}
        ${arg_SOURCES}
    )
    target_link_libraries( ${FEATURE_NAME}
        PRIVATE
            ${arg_LINK_TARGETS}
            cucumber-cpp
    )
    target_include_directories( ${FEATURE_NAME}
        PRIVATE
            "${arg_INCLUDE_DIRS}"
    )

    if(NOT arg_FEATURES_ROOT)
        set(arg_FEATURES_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()

    # Cucumber is run in 2 steps: 
    #   1: Start step executer (blocking) - server
    #   2: Run cucumber which sends step-commands to executer - client
    #   This is done by executing cmake in script mode & do execute_process 
    #   with multiple (paralell) commands.
    #   NOTE: See top of file (invoked by test)

    set(FEATURE_TEST ${FEATURE_NAME}_tests)
    add_test( 
        NAME ${FEATURE_TEST}
        COMMAND 
            "${CMAKE_COMMAND}"
                "-DCUCUMBER_PATH=${CUCUMBER}"
                "-DTEST_TARGET_PATH=$<TARGET_FILE:${FEATURE_NAME}>"
                "-DTEST_FEATURE_PATH=${arg_FEATURES_ROOT}/${arg_FEATURE}"
                -P ${cucumber_testing_path}
        WORKING_DIRECTORY "${arg_FEATURES_ROOT}"
    )

    # Shared settings
    set_tests_properties( ${FEATURE_TEST}
        PROPERTIES 
            TIMEOUT 10
            RUN_SERIAL ON
            LABELS "acceptance"
    )

    get_test_property(${FEATURE_TEST} LABELS TAGS)

    message("CUCUMBER - Feature '${FEATURE_NAME}' setup as test '${FEATURE_TEST}'. Tags: ${TAGS}")
    
endfunction()
