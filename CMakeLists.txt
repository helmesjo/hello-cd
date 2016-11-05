cmake_minimum_required( VERSION 2.8.7 )

project("hello_root")

# Compile flags
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
endif()

# Add external modules
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/modules)
add_subdirectory(${CMAKE_MODULE_PATH}/catch)

# Add projects
add_subdirectory(src)
add_subdirectory(test)

enable_testing()
add_test(NAME ${TEST_PROJECT_NAME} COMMAND ${TEST_PROJECT_NAME})