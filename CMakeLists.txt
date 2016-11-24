cmake_minimum_required( VERSION 3.2.2 )

project("Solution")

# Compile flags
set(CMAKE_CXX_STANDARD 14) # C++14...
set(CMAKE_CXX_STANDARD_REQUIRED ON) #...is required...
set(CMAKE_CXX_EXTENSIONS OFF) #...without compiler extensions like gnu++11

# Add external modules
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/modules/)

add_subdirectory(${CMAKE_MODULE_PATH}/catch)
add_subdirectory(${CMAKE_MODULE_PATH}/cpplocate)
set(cpplocate_DIR ${CMAKE_MODULE_PATH}/cpplocate)

# Add projects
add_subdirectory(src)
add_subdirectory(test)