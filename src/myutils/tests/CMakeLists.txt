# Remember name of project we are testing
set(TEST_TARGET ${PROJECT_NAME})
project(${TEST_TARGET}_tests VERSION ${PROJECT_VERSION} LANGUAGES CXX)

add_executable(${PROJECT_NAME}
	util_tests.cpp
)
set_target_properties(${PROJECT_NAME} 
    PROPERTIES DEBUG_POSTFIX "-d"
)
target_include_directories(${PROJECT_NAME}
	PRIVATE
		include
)
target_link_libraries( ${PROJECT_NAME}
	${TEST_TARGET}
	catch
	fakeit
)

add_test(
	NAME ${PROJECT_NAME} 
	COMMAND ${PROJECT_NAME}
)