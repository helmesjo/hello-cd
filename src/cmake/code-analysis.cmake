find_program(CPPCHECK cppcheck)

# Verify if static analysis is possible

if(NOT CPPCHECK)
    message(WARNING "- Cppcheck not found.")
    set(SKIP_ANALYSIS true)
endif()

# Setup an "ALL"-target linking all targets, allowing: cmake --build . --target static_analysis_all
set(ANALYSIS_ALL static_analysis_all)
if(NOT TARGET ${ANALYSIS_ALL})
    add_custom_target( ${ANALYSIS_ALL} 
        COMMENT "Main target for all static analysis targets."
    )

    message("Target '${ANALYSIS_ALL}' will build all static analysis targets. Run the following to generate reports:\n \
    \tcmake --build . --target static_analysis_all\n \
    \tcmake --build . --target install"
    )
endif()

# ----------------------------------------------------------------------

function(setup_target_for_analysis TARGET)
    if(SKIP_ANALYSIS OR NOT TARGET)
        message("Skipping setting up static analysis for target '${TARGET}'...\n")
        return()
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

    set(TARGET_ANALYSIS ${TARGET}_analysis)
    set(OUTPUT_FILE ${TARGET_BINARY_DIR}/${TARGET_ANALYSIS}.xml)

    add_custom_target( ${TARGET_ANALYSIS}
        # Run cppcheck
        COMMAND ${CPPCHECK} --xml-version=2 --enable=all --force -I ${TARGET_INCLUDES} ${TARGET_SOURCES} 2> ${OUTPUT_FILE}

        DEPENDS ${TARGET}
        WORKING_DIRECTORY ${TARGET_SOURCE_DIR}
        VERBATIM
        COMMENT "Running static analysis (cppcheck) and generating report."
    )

    add_dependencies( ${ANALYSIS_ALL} 
        ${TARGET_ANALYSIS}
    )

    install(
        FILES ${OUTPUT_FILE}
        DESTINATION ./code-analysis
        OPTIONAL
    )

    message("Static analysis setup for target '${TARGET}' in:\n
    \t\"${TARGET_BINARY_DIR}\".\n \
    \tReport found at: \"${OUTPUT_FILE}\"\n"
    )
endfunction()