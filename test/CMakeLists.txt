project(${SRC_NAME}.Tests)

message(${SRC_NAME})
	
# Files to compile
file(GLOB_RECURSE sources *.cpp *.hpp)

# Output
add_executable(${PROJECT_NAME} ${sources})

# Includes Catch in the project:
include_directories(${CATCH_INCLUDE_DIR} ${COMMON_INCLUDES})
add_dependencies(${PROJECT_NAME} catch)
enable_testing(true)  # Enables unit-testing.

# Include tested project
include_directories(${SRC_PATH})
target_link_libraries(${PROJECT_NAME} ${SRC_NAME})