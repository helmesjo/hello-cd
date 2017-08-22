find_program(CPPCHECK cppcheck)
find_program(CPPCHECK_JUNIT cppcheck_junit)
find_program(CPPCHECK_HTML cppcheck-htmlreport)

# Verify if static analysis is possible

if(NOT CPPCHECK)
    message(WARNING "- Cppcheck not found.")
    set(SKIP_ANALYSIS true)
endif()

if(NOT CPPCHECK_JUNIT)
    message(WARNING "- Cppcheck-junit not found.")
    set(SKIP_ANALYSIS true)
endif()

if(NOT CPPCHECK_HTML)
    message(WARNING "- Cppcheck-html not found.")
    set(SKIP_ANALYSIS true)
endif()

# Setup an "ALL"-target linking all targets, allowing: cmake --build . --target static_analysis_all
set(ANALYSIS_ALL static_analysis_all)
if(NOT TARGET ${ANALYSIS_ALL})
    add_custom_target( ${ANALYSIS_ALL} 
        COMMENT "Main target for all static analysis targets."
    )

    message("STATIC ANALYSIS")
    message("- Target '${ANALYSIS_ALL}' will build all static analysis targets. Run the following to generate reports:\n \
    \tcmake --build . --target static_analysis_all\n \
    \tcmake --build . --target install"
    )
endif()

function(setup_target_for_analysis TARGET)
    message("STATIC ANALYSIS")
    if(SKIP_ANALYSIS OR NOT TARGET)
        message("- Skipping setting up static analysis for target '${TARGET}'...\n")
    else()
        setup_target_for_analysis_internal( ${TARGET} )
    endif()
endfunction()

function(setup_target_for_analysis_internal TARGET)
    get_target_property(
        TARGET_BINARY_DIR
        ${TARGET}
        BINARY_DIR
    )

    get_target_property(
        TARGET_SOURCE_DIR
        ${TARGET}
        SOURCE_DIR
    )

    # Get source-files (relative paths, so must run cppcheck from TARGET_SOURCE_DIR)
    get_target_property(
        TARGET_SOURCES
        ${TARGET}
        SOURCES
    )

    # Get include paths and prepend -I (cppcheck include-command)
    get_target_property(
        TARGET_INCLUDES 
        ${TARGET} 
        INCLUDE_DIRECTORIES
    )
    string(REPLACE ";" ";-I" TARGET_INCLUDES "${TARGET_INCLUDES}")

    set(TARGET_ANALYSIS ${TARGET}_static_analysis)
    set(OUTPUT_FILE ${TARGET_BINARY_DIR}/${TARGET_ANALYSIS}.xml)
    set(OUTPUT_FILE_JUNIT ${TARGET_BINARY_DIR}/${TARGET_ANALYSIS}-junit.xml)
    set(OUTPUT_DIR_HTML "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_ANALYSIS}_html")
    
    message(${OUTPUT_DIR_HTML})

    add_custom_target( ${TARGET_ANALYSIS}
        # Run cppcheck
        COMMAND ${CPPCHECK} --xml-version=2 --enable=all --force -I ${TARGET_INCLUDES} ${TARGET_SOURCES} 2> "${OUTPUT_FILE}"
        # Below should (optionally? or always do both?) convert cppcheck format -> junit format. 
        COMMAND ${CPPCHECK_JUNIT} "${OUTPUT_FILE}" "${OUTPUT_FILE_JUNIT}"
        COMMAND ${CPPCHECK_HTML} --report-dir=${OUTPUT_DIR_HTML};--title=${TARGET};--source-dir=${SOURCE_DIR};--file=${OUTPUT_FILE}

        DEPENDS ${TARGET}
        WORKING_DIRECTORY ${TARGET_SOURCE_DIR}
        VERBATIM
        COMMENT "Running static analysis (cppcheck) and generating report."
    )

    add_dependencies( ${ANALYSIS_ALL} 
        ${TARGET_ANALYSIS}
    )

    install(
        FILES "${OUTPUT_FILE}" "${OUTPUT_FILE_JUNIT}"
        DESTINATION ./reports
        OPTIONAL
    )

    install(
        DIRECTORY "${OUTPUT_DIR_HTML}"
        DESTINATION ./reports
        OPTIONAL
    )

    message("- Static analysis setup for target '${TARGET}' in:\n
    \t\"${TARGET_BINARY_DIR}\".\n \
    \tReport found at: \"${OUTPUT_FILE}\"\n"
    )
endfunction()