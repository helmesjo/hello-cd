find_package(cpplocate REQUIRED)

project(${MAIN_PROJECT_NAME}_tests)

# ---------------	METADATA

set(META_PROJECT_NAME ${PROJECT_NAME})
set(META_PROJECT_NAMESPACE ${META_PROJECT_NAME})
set(META_BINARY_NAME ${META_PROJECT_NAME})
set(META_BINARY_PATH ${CMAKE_BINARY_DIR})

# ---------------	PROJECT

file(GLOB_RECURSE sources *.cpp *.hpp)
file(GLOB_RECURSE resources resources/*)
add_executable(${PROJECT_NAME} ${sources} ${resources})
enable_testing(true)
# Set as startup project
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

# ---------------	INCLUDES

include_directories(
	${PROJECT_BINARY_DIR}/config
	${MAIN_PROJECT_DIR}
	${CATCH_INCLUDE_DIR}
)

# ---------------	LINKING

# Includes External libs
add_dependencies(${PROJECT_NAME} catch)
# - CPPLOCATE
target_link_libraries(${PROJECT_NAME} PRIVATE
	${MAIN_PROJECT_NAME}
	cpplocate
)

add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})