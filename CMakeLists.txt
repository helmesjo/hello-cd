cmake_minimum_required( VERSION 2.8.7 )

project("hello_root")

# Compile flags
set(CMAKE_CXX_STANDARD 11) # C++11...
set(CMAKE_CXX_STANDARD_REQUIRED ON) #...is required...
set(CMAKE_CXX_EXTENSIONS OFF) #...without compiler extensions like gnu++11

# Add external modules
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/modules)
add_subdirectory(${CMAKE_MODULE_PATH}/catch)

# Add projects
add_subdirectory(src)
add_subdirectory(test)

enable_testing()
add_test(NAME ${TEST_PROJECT_NAME} COMMAND ${TEST_PROJECT_NAME})