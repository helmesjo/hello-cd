# Find and verify required programs
if(CMAKE_COMPILER_IS_GNUCXX)
    find_program(GCOV gcov)
    find_program(LCOV lcov)
    find_program(GENHTML genhtml)

    if(NOT GCOV)
        message(FATAL_ERROR "Gcov not found.")
    endif()

    if(NOT LCOV)
        message(FATAL_ERROR "Lcov not found.")
    endif()

    if(NOT GENHTML)
        message(FATAL_ERROR "Genhtml not found.")
    endif()
endif()

# Setup an "ALL"-target linking all code coverage targets, allowing: cmake --build . --target coverage_all
set(COVERAGE_ALL coverage_all)
if(NOT TARGET ${COVERAGE_ALL})
    add_custom_target( ${COVERAGE_ALL} 
        COMMENT "Main target for all code coverage targets."
    )
endif()

# ----------------------------------------------------------------------

# Calling to this function will result in no-op if not on GCC or config not Debug
function(setup_target_for_coverage)
    if(NOT CMAKE_COMPILER_IS_GNUCXX OR NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
        message("Code-coverage only available for GCC & Debug configuration, ignoring...\n")
        return()
    else()
        setup_target_for_coverage_internal( ${ARGV} )
    endif()
endfunction()

function(setup_target_for_coverage_internal)
    set(options "")
    set(oneValueArgs
        TARGET
        TEST_RUNNER
    )
    set(multiValueArgs "")
    cmake_parse_arguments(args "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Set compile flags to produce coverage files, and make sure dependant targets link correctly.
    target_compile_options( ${args_TARGET}
	    PRIVATE
		    -g -O0 --coverage
    )
    target_link_libraries( ${args_TARGET}
        PRIVATE
            --coverage
    )

    get_property(
        TARGET_BINARY_DIR
        TARGET ${args_TARGET}
        PROPERTY BINARY_DIR
    )

    set(TARGET_COVERAGE ${args_TARGET}_coverage)
    add_custom_target( ${TARGET_COVERAGE}
        # Cleanup lcov
        COMMAND ${LCOV} --directory . --zerocounters
        # Run tests
        COMMAND ${args_TEST_RUNNER}
        # Generating report
        COMMAND ${LCOV} --directory . --capture --output-file ${TARGET_COVERAGE}.info
        COMMAND ${GENHTML} -o ${TARGET_COVERAGE} ${TARGET_COVERAGE}.info

        DEPENDS ${args_TEST_RUNNER}
        WORKING_DIRECTORY ${TARGET_BINARY_DIR}
        COMMENT "Resetting code coverage counters to zero.\nProcessing code coverage counters and generating report."
    )

    install(
        DIRECTORY "${TARGET_BINARY_DIR}/${TARGET_COVERAGE}" 
        DESTINATION "code-analysis" 
        OPTIONAL
    )

    add_dependencies( ${COVERAGE_ALL} 
        ${TARGET_COVERAGE}
    )

    message("Code coverage setup for target '${args_TARGET}' in: ${TARGET_BINARY_DIR}.\n \
    \tOutput found in: ${TARGET_BINARY_DIR}/${TARGET_COVERAGE}\n \
    \tCreated target '${COVERAGE_ALL}' that will build all code-coverage targets.\n"
    )
endfunction()
