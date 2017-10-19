project(end_to_end_tests VERSION 0.1 LANGUAGES CXX)

add_executable( ${PROJECT_NAME}
	features/step_definitions/walking_skeleton.cpp
)
target_link_libraries(${PROJECT_NAME}
	PRIVATE
		hello_cd::mylib
		Boost::boost 
		Boost::thread 
		Boost::system 
		Boost::regex 
		Boost::date_time 
		Boost::program_options 
		Boost::filesystem
		cucumber-cpp
)

set_target_properties(${PROJECT_NAME} 
	PROPERTIES
    	CXX_STANDARD 14
    	CXX_STANDARD_REQUIRED ON
    	CXX_EXTENSIONS OFF
		DEBUG_POSTFIX "-d"
)