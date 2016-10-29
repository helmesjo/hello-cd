project("hello-cmake")

# Files to compile
file(GLOB_RECURSE sources *.cpp *.hpp)

# Output
add_library(${PROJECT_NAME} STATIC ${sources})

set(SRC_NAME ${PROJECT_NAME} PARENT_SCOPE)