cmake_minimum_required(VERSION 3.5)
project(hello_cd VERSION 0.1 LANGUAGES CXX)

# Following guide: https://rix0r.nl/blog/2015/08/13/cmake-guide/

# Must use GNUInstallDirs to install libraries into correct
# locations on all platforms.
include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

# Make find_package work with upstream targets
include(EnableUpstreamTargets)

# Setup Conan packages
add_definitions("-std=c++11")
include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup(NO_OUTPUT_DIRS ON)

enable_testing()

add_subdirectory(src)
add_subdirectory(tests)