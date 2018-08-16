find_package(catch2 REQUIRED)
find_package(FakeIt REQUIRED)

function(add_test_internal)
    set(oneValueArgs
        TEST_TARGET
        TEST_NAME
        REPORT_FILE
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
    target_compile_definitions( ${arg_TEST_NAME}
        PRIVATE 
            CATCH_CONFIG_MAIN=1
    )

    add_test(
        NAME ${arg_TEST_NAME} 
        COMMAND ${arg_TEST_NAME} ${arg_TEST_ARGS}
    )
    set_tests_properties(${arg_TEST_NAME} PROPERTIES LABELS ${arg_TAGS})

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
    
    add_test_internal( ${ARGV}
        TEST_ARGS --reporter junit --out "${arg_TEST_NAME}.xml"
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