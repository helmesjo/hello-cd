project(${MAIN_PROJECT_NAME}.tests)
set(PROJECT_NAMESPACE "tests")

# Files to compile
file(GLOB_RECURSE sources *.cpp *.hpp)
# Resources
file(GLOB_RECURSE resources resources/*)

# Output
add_executable(${PROJECT_NAME} ${sources} ${resources})

# Move resource files into sub-dir in project
source_group(Resources FILES ${resources})

# On build, copy resource-files to output folder
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
		"${PROJECT_SOURCE_DIR}/resources"
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/resources)

set_property(DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})

# Includes Catch in the project:
include_directories(${CATCH_INCLUDE_DIR} ${COMMON_INCLUDES})
add_dependencies(${PROJECT_NAME} catch)
enable_testing(true)  # Enables unit-testing.

# Include tested project
include_directories(${MAIN_PROJECT_DIR})
target_link_libraries(${PROJECT_NAME} ${MAIN_PROJECT_NAME})

set(TEST_PROJECT_NAME ${PROJECT_NAME} PARENT_SCOPE)
set(TEST_PROJECT_DIR ${PROJECT_SOURCE_DIR} PARENT_SCOPE)