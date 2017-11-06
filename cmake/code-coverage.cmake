find_program(GCOV gcov)
find_program(LCOV lcov)
find_program(GENHTML genhtml)

# Verify if code coverage is possible

if (NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    message("CODE COVERAGE - Current compiler is ${CMAKE_CXX_COMPILER_ID}. Code-coverage only available for GCC.")
    set(SKIP_COVERAGE true)

elseif(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
    message("CODE COVERAGE - Code-coverage only available when building for Debug.\n")
    set(SKIP_COVERAGE true)

elseif(NOT GCOV)
    message("CODE COVERAGE - Gcov not found.")
    set(SKIP_COVERAGE true)

elseif(NOT LCOV)
    message("CODE COVERAGE - Lcov not found.")
    set(SKIP_COVERAGE true)

elseif(NOT GENHTML)
    message("CODE COVERAGE - Genhtml not found.")
    set(SKIP_COVERAGE true)
endif()

# Setup an "ALL"-target linking all code coverage targets, allowing: cmake --build . --target coverage_all
set(COVERAGE_ALL coverage_all)
if(NOT TARGET ${COVERAGE_ALL})
    add_custom_target( ${COVERAGE_ALL} 
        COMMENT "Main target for all code coverage targets."
    )
    message("CODE COVERAGE - To generate reports: `cmake --build . --target coverage_all`")
endif()

# Calling to this function will result in no-op if not on GCC or config not Debug
function(setup_target_for_coverage)
    if(SKIP_COVERAGE)
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

    set(TARGET_COVERAGE ${args_TARGET}_coverage_analysis)
    set(OUTPUT_DIR ${TARGET_BINARY_DIR}/${TARGET_COVERAGE})
    set(OUTPUT_FILE ${OUTPUT_DIR}/${args_TARGET}.info)

    add_custom_target( ${TARGET_COVERAGE}
        # Cleanup lcov
        COMMAND ${LCOV} --directory . --zerocounters
        # Run tests
        COMMAND ${args_TEST_RUNNER}
        # Generating report
        COMMAND ${CMAKE_COMMAND} -E make_directory ${OUTPUT_DIR}
        COMMAND ${LCOV} --directory . --capture --output-file "${OUTPUT_FILE}"
        COMMAND ${GENHTML} --output-directory "${OUTPUT_DIR}" "${OUTPUT_FILE}"

        DEPENDS ${args_TEST_RUNNER}
        WORKING_DIRECTORY ${TARGET_BINARY_DIR}
        COMMENT "Resetting code coverage counters to zero.\nProcessing code coverage counters and generating report."
    )

    add_dependencies( ${COVERAGE_ALL} 
        ${TARGET_COVERAGE}
    )

    install(
        DIRECTORY "${OUTPUT_DIR}"
        DESTINATION ./reports
        OPTIONAL
    )

    message("CODE COVERAGE - Analysis setup for target '${args_TARGET}'")
endfunction()
