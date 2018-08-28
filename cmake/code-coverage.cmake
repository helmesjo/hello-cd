find_program(GCOV gcov)
find_program(LCOV lcov)
find_program(GENHTML genhtml)

# Verify if code coverage is possible

if (NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    message("CODE COVERAGE - Current compiler is ${CMAKE_CXX_COMPILER_ID}. Code-coverage only available for GCC.")
    set(SKIP_COVERAGE true)

elseif(NOT CMAKE_BUILD_TYPE STREQUAL "Debug" AND NOT CMAKE_BUILD_TYPE STREQUAL "Coverage")
    message("CODE COVERAGE - Code-coverage only available when building for Debug or Coverage.\n")
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

    # Set flags to produce coverage files when compiling target
    target_compile_options( ${args_TARGET}
	    PRIVATE
		    -g -O0 --coverage
    )
    target_link_libraries( ${args_TARGET}
        PRIVATE
            --coverage
    )

    get_target_property(TARGET_BINARY_DIR ${args_TARGET} BINARY_DIR)
    get_target_property(TARGET_SOURCE_DIR ${args_TARGET} SOURCE_DIR)

    set(TARGET_COVERAGE ${args_TARGET}_coverage_analysis)
    set(HTML_OUTPUT_DIR "${TARGET_BINARY_DIR}/${TARGET_COVERAGE}")
    set(GCOV_INFO_FILE "${args_TARGET}_coverage.info")
    set(GCOV_INFO_FILE_FILTERED "${args_TARGET}_coverage_filtered.info")

    # Root dir use to extract relevant coverage info (only include this targets sources' in report)

    add_custom_target( ${TARGET_COVERAGE}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${TARGET_COVERAGE}
        # Reset execution counters
        COMMAND ${LCOV} --directory . --zerocounters
        # Run tests
        COMMAND "./$<TARGET_FILE_NAME:${args_TEST_RUNNER}>"
        # Create test coverage data
        COMMAND ${LCOV} --directory . --capture --output-file ${GCOV_INFO_FILE}
        # Filter out relevant info
        COMMAND ${LCOV} --directory . --extract ${GCOV_INFO_FILE} '${TARGET_SOURCE_DIR}/*' --output-file ${GCOV_INFO_FILE_FILTERED}
        # Generating report
        COMMAND ${GENHTML} --output-directory "${HTML_OUTPUT_DIR}" ${GCOV_INFO_FILE_FILTERED}

        DEPENDS ${args_TEST_RUNNER}
        WORKING_DIRECTORY "${TARGET_BINARY_DIR}"
        COMMENT "Running code coverage analysis (gcov) and generating HTML report (genhtml)."
    )

    add_dependencies( ${COVERAGE_ALL} 
        ${TARGET_COVERAGE}
    )

    install(
        DIRECTORY "${HTML_OUTPUT_DIR}"
        DESTINATION ./reports
        OPTIONAL
    )

    message("CODE COVERAGE - Analysis setup for target '${args_TARGET}'")
endfunction()
