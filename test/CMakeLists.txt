set(testProjectName ${PROJECT_NAME}.UnitTests)
	
# Files to compile
file(GLOB_RECURSE sources *.cpp *.hpp)

# Output
add_executable(${testProjectName} ${sources})

# Includes Catch in the project:
include_directories(${CATCH_INCLUDE_DIR} ${COMMON_INCLUDES})
add_dependencies(${testProjectName} catch)
enable_testing(true)  # Enables unit-testing.

# Include tested project
include_directories(${CMAKE_SOURCE_DIR}/${project_path})
target_link_libraries(${testProjectName} ${PROJECT_NAME})