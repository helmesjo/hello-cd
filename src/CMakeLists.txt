# Files to compile
file(GLOB_RECURSE sources *.cpp *.hpp )

# Output
add_library(${PROJECT_NAME} STATIC ${sources})