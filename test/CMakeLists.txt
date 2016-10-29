set(testProjectName ${PROJECT_NAME}.UnitTests)
	
# Files to compile
file(GLOB_RECURSE sources *.cpp *.hpp)

# Output
add_executable(${testProjectName} ${sources})

# Make available
include_directories(${CMAKE_SOURCE_DIR}/${project_path})
target_link_libraries(${testProjectName} ${PROJECT_NAME})