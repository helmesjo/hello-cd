project(end_to_end_tests VERSION 0.1 LANGUAGES CXX)

find_package(mylib REQUIRED)

include(cucumber-testing)

add_cucumber_test(
	FEATURE "features/walking_skeleton.feature"
	STEP_DEFINITIONS "features/step_definitions/walking_skeleton.cpp"
	TARGETS 
		${CMAKE_PROJECT_NAME}::mylib
)