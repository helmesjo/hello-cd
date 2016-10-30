project("hello-cmake")

# Files to compile
file(GLOB_RECURSE sources *.cpp *.hpp)

# Output
add_library(${PROJECT_NAME} STATIC ${sources})

set(HELLO_CMAKE_NAME ${PROJECT_NAME} PARENT_SCOPE)
set(HELLO_CMAKE_DIR ${PROJECT_SOURCE_DIR} PARENT_SCOPE)