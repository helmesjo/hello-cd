project("hello-cmake")

# Files to compile
file(GLOB_RECURSE sources *.cpp *.hpp)
# Resources
file(GLOB_RECURSE resources res/*)

# Output
add_library(${PROJECT_NAME} STATIC ${sources} ${resources})

# Move resource files into sub-dir in project
source_group(Resources FILES ${resources})

# On build, copy resource-files to output folder
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
		"${PROJECT_SOURCE_DIR}/res"
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/res)

set(MAIN_PROJECT_NAME ${PROJECT_NAME} PARENT_SCOPE)
set(MAIN_PROJECT_DIR ${PROJECT_SOURCE_DIR} PARENT_SCOPE)