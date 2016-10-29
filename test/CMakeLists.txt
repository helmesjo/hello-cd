set(source "src/")

# Folders to include
include_directories(
	${source}
	)

# Linking
#target_link_libraries(${PROJECT_NAME})
	
# Files to compile
file(GLOB_RECURSE sources ${source}*.cpp ${source}*.hpp )

# Output
add_executable(${PROJECT_NAME}.Tests ${sources})