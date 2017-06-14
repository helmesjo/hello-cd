cmake_minimum_required(VERSION 3.2.2 FATAL_ERROR)

# Following guide: https://rix0r.nl/blog/2015/08/13/cmake-guide/

# Must use GNUInstallDirs to install libraries into correct
# locations on all platforms.
include(GNUInstallDirs)

enable_testing()
add_subdirectory(src)