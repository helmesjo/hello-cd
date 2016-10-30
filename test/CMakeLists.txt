project(${HELLO_CMAKE_NAME}.tests)
	
# Files to compile
file(GLOB_RECURSE sources *.cpp *.hpp)

# Output
add_executable(${PROJECT_NAME} ${sources})
set_property(DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})

# Includes Catch in the project:
include_directories(${CATCH_INCLUDE_DIR} ${COMMON_INCLUDES})
add_dependencies(${PROJECT_NAME} catch)
enable_testing(true)  # Enables unit-testing.

# Include tested project
include_directories(${HELLO_CMAKE_DIR})
target_link_libraries(${PROJECT_NAME} ${HELLO_CMAKE_NAME})