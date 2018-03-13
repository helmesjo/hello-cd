project(end_to_end_tests VERSION 0.1 LANGUAGES CXX)

find_package(mylib REQUIRED)

include(cucumber-testing)
include(configure_file)

add_cucumber_test(
	FEATURE "features/walking_skeleton.feature"
	STEP_DEFINITIONS "features/step_definitions/walking_skeleton.cpp"
	INCLUDE_DIRS "${PROJECT_BINARY_DIR}"
	LINK_TARGETS 
		${CMAKE_PROJECT_NAME}::mylib
)

# Target is only defined if 'cucumber' is present
if(TARGET walking_skeleton)
	configure_file_buildtime(
		TARGET walking_skeleton
		FILE_IN "${PROJECT_SOURCE_DIR}/test_info.h.in"
		FILE_OUT "test_info.h"
		VARIABLES
			"PROJECT_NAMESPACE=${CMAKE_PROJECT_NAME}"
			"PROJECT_NAME=${PROJECT_NAME}"
	)
endif()