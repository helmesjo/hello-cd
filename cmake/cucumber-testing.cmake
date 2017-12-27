find_program(CUCUMBER cucumber)

# Tests are run in descending order (higher cost first)
# We use this to make sure steprunner is started before cucumber-feature when run in parallel
# (steprunner blocks & waits for cucumber-feature to send steps to execute)
if(NOT TEST_COST)
    set(TEST_COST "100000000")
endif()

if(NOT CUCUMBER)
    message("TESTING - Cucumber not found, skipping acceptance tests.")
    set(SKIP true)
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
        STEP_DEFINITIONS
        TARGETS
    )
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    get_filename_component(FEATURE_NAME ${arg_FEATURE} NAME_WE)

    add_executable( ${FEATURE_NAME}
        ${arg_STEP_DEFINITIONS}
    )
    target_link_libraries( ${FEATURE_NAME}
        PRIVATE
            ${arg_TARGETS}
            cucumber-cpp
    )

    if(NOT arg_FEATURES_ROOT)
        set(arg_FEATURES_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()

    # Cucumber is run in 2 steps: 
    #   1: Start step executer (blocking)
    #   2: Run cucumber which sends step-commands to executer
    # NOTE: ctest must be run in parallel mode (`ctest --parallel 2`), else it will freeze.
    add_test(
        NAME ${FEATURE_NAME}_steprunner
        COMMAND ${FEATURE_NAME}
    )
    decrement_cost_and_set_for_test( TEST ${FEATURE_NAME}_steprunner )
    
    add_test(
        NAME ${FEATURE_NAME}
        COMMAND ${CUCUMBER} --strict "${CMAKE_CURRENT_SOURCE_DIR}/${arg_FEATURE}"
        WORKING_DIRECTORY ${arg_FEATURES_ROOT}
    )
    decrement_cost_and_set_for_test( TEST ${FEATURE_NAME} )

    # Shared settings
    set_tests_properties( ${FEATURE_NAME} ${FEATURE_NAME}_steprunner 
        PROPERTIES 
            TIMEOUT 10
            PARALLEL_LEVEL 2
            PROCESSORS 1
            LABELS "acceptance"
    )
    
endfunction()

function(decrement_cost_and_set_for_test)
    set(oneValueArgs
        TEST
    )
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    math(EXPR TEST_COST "${TEST_COST}-1")
    set(TEST_COST ${TEST_COST} PARENT_SCOPE)

    set_tests_properties( ${arg_TEST}
        PROPERTIES 
            COST ${TEST_COST}
    )

endfunction()
