cmake_minimum_required( VERSION 3.6 )

project(hello_solution)

# Setup paths
set(SRC_PATH ${CMAKE_SOURCE_DIR}/src)
set(TEST_PATH ${CMAKE_SOURCE_DIR}/test)
set(MODULES_PATH ${CMAKE_SOURCE_DIR}/modules ${CMAKE_MODULE_PATH})

# Includes Catch in the project:
add_subdirectory(${MODULES_PATH}/catch)

# Projects
add_subdirectory(${SRC_PATH})
add_subdirectory(${TEST_PATH})