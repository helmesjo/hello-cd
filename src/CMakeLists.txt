cmake_minimum_required(VERSION 3.8 FATAL_ERROR)
project(hello_ci VERSION 0.1 LANGUAGES CXX)

# Include external libs
add_subdirectory(external/catch)
add_subdirectory(external/fakeit)

# Targets that we develop here
enable_testing()
add_subdirectory(myutils)
add_subdirectory(mylib)
add_subdirectory(myapp)