cmake_minimum_required(VERSION 3.2.2)
project(hello_ci VERSION 0.1 LANGUAGES CXX)

# Following guide: https://rix0r.nl/blog/2015/08/13/cmake-guide/

# Must use GNUInstallDirs to install libraries into correct
# locations on all platforms.
include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

# Include external libs
add_subdirectory(external/catch)
add_subdirectory(external/fakeit)

# Targets that we develop here
enable_testing()
add_subdirectory(myutils)
add_subdirectory(mylib)
add_subdirectory(myapp)