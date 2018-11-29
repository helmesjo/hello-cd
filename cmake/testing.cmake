find_package(catch2 REQUIRED)
find_package(FakeIt REQUIRED)

option(TESTING_GENERATE_JUNIT_REPORTS "If true, tests will generate a junit report to a .xml file instead of writing to console" FALSE )

function(add_test_internal)
    set(oneValueArgs
        TEST_TARGET
        TEST_NAME
        REPORT_FILE
        NO_MAIN
    )
    set(multiValueArgs
        TEST_ARGS
        SOURCES
        INCLUDE_DIRS
        TAGS
    )
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    add_executable( ${arg_TEST_NAME}
        ${arg_SOURCES}
    )

    # Extract properties and apply to test-target
    get_target_property(CXX_STANDARD ${arg_TEST_TARGET} CXX_STANDARD)
    get_target_property(CXX_STANDARD_REQUIRED ${arg_TEST_TARGET} CXX_STANDARD_REQUIRED)
    get_target_property(CXX_EXTENSIONS ${arg_TEST_TARGET} CXX_EXTENSIONS)
    get_target_property(DEBUG_POSTFIX ${arg_TEST_TARGET} DEBUG_POSTFIX)

    set_target_properties( ${arg_TEST_NAME} 
        PROPERTIES 
            CXX_STANDARD ${CXX_STANDARD}
            CXX_EXTENSIONS ${CXX_EXTENSIONS}
            CXX_STANDARD_REQUIRED ${CXX_STANDARD_REQUIRED}
            DEBUG_POSTFIX ${DEBUG_POSTFIX}
    )
    target_include_directories( ${arg_TEST_NAME}
        PRIVATE
            ${arg_INCLUDE_DIRS}
    )
    target_link_libraries( ${arg_TEST_NAME}
        PRIVATE
            ${arg_TEST_TARGET}
            catch2::catch2
            FakeIt::FakeIt
    )

    if(NOT arg_NO_MAIN)
        define_catch_main_for_target(${arg_TEST_NAME})
    endif()

    add_test(
        NAME ${arg_TEST_NAME} 
        COMMAND ${arg_TEST_NAME} ${arg_TEST_ARGS}
    )
    set_tests_properties(${arg_TEST_NAME} PROPERTIES LABELS ${arg_TAGS})
    # FakeIt is not reliable with optimizations
    target_compile_options(${arg_TEST_NAME} PUBLIC "$<$<CONFIG:RELEASE>:-O0>")

    get_target_property(OUT_DIR ${arg_TEST_NAME} BINARY_DIR)
    install(
        FILES "${OUT_DIR}/${arg_REPORT_FILE}"
        DESTINATION ./reports
        OPTIONAL
    )

    message("TESTING - Test '${arg_TEST_NAME}' setup for target '${arg_TEST_TARGET}'. Tags: ${arg_TAGS}")

endfunction()

function(add_catch_test)
    set(oneValueArgs
        TEST_NAME
    )
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    if(TESTING_GENERATE_JUNIT_REPORTS)
        set(REPORTER_ARGS --reporter junit --out "${arg_TEST_NAME}.xml")
    endif()

    add_test_internal( ${ARGV}
        TEST_ARGS ${REPORTER_ARGS}
        REPORT_FILE "${arg_TEST_NAME}.xml"
    )
endfunction()

function(add_unit_test)
    add_catch_test(${ARGV} TAGS "unit")
endfunction()

function(add_integration_test)
    add_catch_test(${ARGV} TAGS "integration")
endfunction()

function(add_performance_test)
    add_catch_test(${ARGV} TAGS "performance")
endfunction()



# We generate an include a header that defines CATCH_CONFIG_MAIN, includes catch then undefines CATCH_CONFIG_MAIN
function(define_catch_main_for_target TARGET)

    get_target_property(TARGET_BINARY_DIR ${TARGET} BINARY_DIR)
    set(CPP_FILE "${TARGET_BINARY_DIR}/define_catch_main.cpp")

    if(NOT EXISTS "${CPP_FILE}")
        set(CPP_SOURCE "\
        #define CATCH_CONFIG_MAIN \n
        #include <catch.hpp> \n
        #undef CATCH_CONFIG_MAIN")
        file(WRITE "${CPP_FILE}" "${CPP_SOURCE}")
    endif()

    target_sources(${TARGET} PRIVATE ${CPP_FILE})
endfunction()
