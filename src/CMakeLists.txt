project("hellocmake" CXX)

# ---------------	METADATA

set(META_PROJECT_NAME ${PROJECT_NAME})
set(META_PROJECT_NAMESPACE ${META_PROJECT_NAME})
set(META_PROJECT_VERSION_MAJOR 0)
set(META_PROJECT_VERSION_MINOR 1)
set(META_BINARY_NAME ${META_PROJECT_NAME})
set(META_BINARY_PATH ${CMAKE_BINARY_DIR})

# ---------------	GROUP FILES

file(GLOB_RECURSE sources *.cpp *.hpp)
file(GLOB_RECURSE resources resources/*)
source_group(Resources FILES ${resources})

# ---------------	BUILD

add_library(${PROJECT_NAME} 
	STATIC 
	${sources} 
	${resources}
)
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
)

	
set(MAIN_PROJECT_NAME ${PROJECT_NAME} PARENT_SCOPE)
set(MAIN_PROJECT_DIR ${PROJECT_SOURCE_DIR} PARENT_SCOPE)