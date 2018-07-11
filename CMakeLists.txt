cmake_minimum_required(VERSION 3.5)
project(hello_cd VERSION 0.1 LANGUAGES CXX)

# Following guide: https://rix0r.nl/blog/2015/08/13/cmake-guide/

# Must use GNUInstallDirs to install libraries into correct
# locations on all platforms.
include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_BINARY_DIR}")

# Make find_package work with upstream targets
include(EnableUpstreamTargets)

enable_testing()

add_subdirectory(src)
add_subdirectory(tests)