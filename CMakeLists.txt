cmake_minimum_required( VERSION 3.2.2 )

enable_testing(true)

# ---------------	COMPILE FLAGS

set(CMAKE_CXX_STANDARD 14) # C++14...
set(CMAKE_CXX_STANDARD_REQUIRED ON) #...is required...
set(CMAKE_CXX_EXTENSIONS OFF) #...without compiler extensions like gnu++11

# ---------------	EXTERNAL MODULES

set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/modules)

add_subdirectory(${CMAKE_MODULE_PATH}/catch)
add_subdirectory(${CMAKE_MODULE_PATH}/fakeit)
add_subdirectory(${CMAKE_MODULE_PATH}/cpplocate)
set(cpplocate_DIR ${CMAKE_MODULE_PATH}/cpplocate)

# ---------------   OUTPUT DIRS

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/output)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/output)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/output)

# ---------------	BUILD LIB & TESTS
add_subdirectory(src)
add_subdirectory(test)