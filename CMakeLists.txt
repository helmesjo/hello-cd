cmake_minimum_required( VERSION 3.6 )

set(PROJECT_NAME "hello-ci")

project(${PROJECT_NAME})

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
  # using Visual Studio C++
  
  # Force to always compile with W4
  if(CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
    string(REGEX REPLACE "/W[0-4]" "/W4" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4")
  endif()
endif()

# Folders to include
include_directories( src )
include_directories( test )

# Files to compile
file(GLOB_RECURSE sources src/*.cpp src/*.hpp )

# Main executable
add_library(${PROJECT_NAME} STATIC ${sources})