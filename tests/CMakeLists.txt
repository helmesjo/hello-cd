project(end_to_end_tests VERSION 0.1 LANGUAGES CXX)

add_executable( ${PROJECT_NAME}
	features/step_definitions/walking_skeleton.cpp
)
target_link_libraries(${PROJECT_NAME}
	PRIVATE
		hello_cd::mylib
		cucumber-cpp
)