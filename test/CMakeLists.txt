project(${HELLO_CMAKE_NAME}.tests)
	
# Files to compile
file(GLOB_RECURSE sources *.cpp *.hpp)

# Output
add_executable(${PROJECT_NAME} ${sources})

# Includes Catch in the project:
include_directories(${CATCH_INCLUDE_DIR} ${COMMON_INCLUDES})
add_dependencies(${PROJECT_NAME} catch)
enable_testing(true)  # Enables unit-testing.

# Include tested project
include_directories(${HELLO_CMAKE_DIR})
target_link_libraries(${PROJECT_NAME} ${HELLO_CMAKE_NAME})