find_package(catch QUIET)
find_package(fakeit QUIET)

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
    get_target_property(DEBUG_POSTFIX ${arg_TEST_TARGET} DEBUG_POSTFIX)
    set_target_properties( ${arg_TEST_NAME} 
        PROPERTIES 
            DEBUG_POSTFIX ${DEBUG_POSTFIX}
    )
    target_include_directories( ${arg_TEST_NAME}
        PRIVATE
            ${arg_INCLUDE_DIRS}
    )
    target_link_libraries( ${arg_TEST_NAME}
        PRIVATE
            ${arg_TEST_TARGET}
            catch
            fakeit
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

    message("- Test '${arg_TEST_NAME}' setup for target '${arg_TEST_TARGET}'.\n
    \tTarget found at: \"${OUT_DIR}\"\n \
    \tReport found at: \"${OUT_DIR}/${arg_REPORT_FILE}\n \
    \tTags: \"${arg_TAGS}\"\n"
    )

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