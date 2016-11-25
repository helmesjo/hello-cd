find_package(cpplocate REQUIRED)

project(${MAIN_PROJECT_NAME}_tests CXX)

# ---------------	METADATA

set(META_PROJECT_NAME ${PROJECT_NAME})
set(META_PROJECT_NAMESPACE ${META_PROJECT_NAME})
set(META_BINARY_NAME ${META_PROJECT_NAME})
set(META_BINARY_PATH ${CMAKE_BINARY_DIR})

# ---------------	GROUP FILES

file(GLOB_RECURSE sources *.cpp *.hpp)
file(GLOB_RECURSE resources resources/*)
source_group(Resources FILES ${resources})

# ---------------	BUILD

add_executable(${PROJECT_NAME} ${sources} ${resources})
# Set as startup project
set_property(DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})
# On build, copy resource-files to output folder
add_custom_command(TARGET ${PROJECT_NAME} 
	POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
		"${PROJECT_SOURCE_DIR}/resources"
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/resources
)

# ---------------	CONFIGURE

configure_file(
    ${PROJECT_SOURCE_DIR}/config/config.h.in
    ${PROJECT_BINARY_DIR}/config/config.h
)
configure_file(
    ${PROJECT_SOURCE_DIR}/config/resources.h.in
    ${PROJECT_BINARY_DIR}/config/resources.h
)

# ---------------	INCLUDE DIRECTORIES

target_include_directories(${PROJECT_NAME}
	PRIVATE
	${PROJECT_BINARY_DIR}/config
	${MAIN_PROJECT_DIR}
	${CATCH_INCLUDE_DIR}
	${cpplocate_SOURCE_DIR}
	${COMMON_INCLUDES}
)

# ---------------	LINKING

add_dependencies(${PROJECT_NAME} 
	catch
)
target_link_libraries(${PROJECT_NAME}
	PRIVATE
	${MAIN_PROJECT_NAME}
	cpplocate
)

add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})