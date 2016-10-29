set(source "src/")
set(testProjectName ${PROJECT_NAME}.UnitTests)

# Folders to include
include_directories(
	${source}
	)

# Linking
#target_link_libraries(${PROJECT_NAME})
	
# Files to compile
file(GLOB_RECURSE sources ${source}*.cpp ${source}*.hpp )

# Output
add_executable(${testProjectName} ${sources})

# Make available
target_link_libraries(${testProjectName} ${PROJECT_NAME})