find_package(cpplocate REQUIRED)

project(${MAIN_PROJECT_NAME}_tests)

set(META_PROJECT_NAME ${PROJECT_NAME})
set(META_PROJECT_NAMESPACE ${META_PROJECT_NAME})
set(META_BINARY_NAME ${META_PROJECT_NAME})
set(META_BINARY_PATH ${CMAKE_BINARY_DIR})

# Files to compile
file(GLOB_RECURSE sources *.cpp *.hpp)
# Resources
file(GLOB_RECURSE resources resources/*)

# Output
add_executable(${PROJECT_NAME} ${sources} ${resources})
set_property(DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})

# Move resource files into sub-dir in project
source_group(Resources FILES ${resources})

# On build, copy resource-files to output folder
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
		"${PROJECT_SOURCE_DIR}/resources"
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/resources)

# Configure header
configure_file(
    ${PROJECT_SOURCE_DIR}/config/config.h.in
    ${PROJECT_BINARY_DIR}/config/config.h
)
# Resource header
configure_file(
    ${PROJECT_SOURCE_DIR}/config/resources.h.in
    ${PROJECT_BINARY_DIR}/config/resources.h
)
include_directories(${PROJECT_BINARY_DIR}/config)

# Includes External libs
# - CATCH
include_directories(${CATCH_INCLUDE_DIR} ${COMMON_INCLUDES})
add_dependencies(${PROJECT_NAME} catch)
enable_testing(true)  # Enables unit-testing.
# - CPPLOCATE
target_link_libraries(${PROJECT_NAME} cpplocate)

# Include tested project
include_directories(${MAIN_PROJECT_DIR})
target_link_libraries(${PROJECT_NAME} ${MAIN_PROJECT_NAME})

set(TEST_PROJECT_NAME ${PROJECT_NAME} PARENT_SCOPE)
set(TEST_PROJECT_DIR ${PROJECT_SOURCE_DIR} PARENT_SCOPE)