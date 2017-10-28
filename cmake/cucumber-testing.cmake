find_program(CUCUMBER cucumber)

if(NOT CUCUMBER)
    message(WARNING "- Cucumber not found, skipping acceptance tests.")
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
    set_tests_properties( ${FEATURE_NAME}_steprunner PROPERTIES LABELS "acceptance")
    set_tests_properties( ${FEATURE_NAME}_steprunner 
        PROPERTIES 
            TIMEOUT 10
            PARALLEL_LEVEL 2
            PROCESSORS 2
    )
    add_test(
        NAME ${FEATURE_NAME}
        COMMAND ${CUCUMBER} "${CMAKE_CURRENT_SOURCE_DIR}/${arg_FEATURE}"
        WORKING_DIRECTORY ${arg_FEATURES_ROOT}
    )
    set_tests_properties( ${FEATURE_NAME} PROPERTIES LABELS "acceptance")
    
endfunction()