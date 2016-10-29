cmake_minimum_required( VERSION 3.6 )

set(PROJECT_NAME "hello-cmake")
set(SOURCE_PATH "src/")
set(TESTSOURCE_PATH "test/src/")

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
include_directories( ${SOURCE_PATH} )
include_directories( ${TESTSOURCE_PATH} )

# Files to compile
file(GLOB_RECURSE sources ${SOURCE_PATH}*.cpp ${SOURCE_PATH}*.hpp )
file(GLOB_RECURSE testsources ${TESTSOURCE_PATH}*.cpp ${TESTSOURCE_PATH}*.hpp )

# Main executable
add_library(${PROJECT_NAME} STATIC ${sources})
add_executable(${PROJECT_NAME}.Tests ${testsources})