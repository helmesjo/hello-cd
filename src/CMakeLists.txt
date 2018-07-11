cmake_minimum_required(VERSION 3.2.2)

# Include external libs
add_subdirectory(external/catch)
add_subdirectory(external/fakeit)

# Targets that we develop here
add_subdirectory(myutils)
add_subdirectory(mylib)
add_subdirectory(myapp)