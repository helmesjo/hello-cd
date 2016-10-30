project("hello-cmake")

# Files to compile
file(GLOB_RECURSE sources *.cpp *.hpp)

# Output
add_library(${PROJECT_NAME} STATIC ${sources})

set(MAIN_PROJECT_NAME ${PROJECT_NAME} PARENT_SCOPE)
set(MAIN_PROJECT_DIR ${PROJECT_SOURCE_DIR} PARENT_SCOPE)