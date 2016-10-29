cmake_minimum_required( VERSION 3.6 )

project("hello-cmake")

set(project_path "src/")
set(test_path "test/src")

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
add_subdirectory(${project_path})
add_subdirectory(${test_path})