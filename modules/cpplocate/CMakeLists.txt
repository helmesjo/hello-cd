cmake_minimum_required(VERSION 2.8.8)
project(cpplocate_builder CXX)
include(ExternalProject)
find_package(Git REQUIRED)

ExternalProject_Add(
    cpplocate
    PREFIX ${CMAKE_BINARY_DIR}/cpplocate
    GIT_REPOSITORY https://github.com/cginternals/cpplocate.git
    TIMEOUT 10
    UPDATE_COMMAND ${GIT_EXECUTABLE} pull
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    LOG_DOWNLOAD ON
   )

# Expose required variable (CPPLOCATE_INCLUDE_DIR) to parent scope
ExternalProject_Get_Property(cpplocate source_dir)
set(CPPLOCATE_INCLUDE_DIR ${source_dir}/source/cpplocate/include/ CACHE INTERNAL "Path to include folder for cpplocate")