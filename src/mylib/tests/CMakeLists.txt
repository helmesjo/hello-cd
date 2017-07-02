# Remember name of project we are testing
set(TEST_TARGET ${PROJECT_NAME})
project(${TEST_TARGET}_tests VERSION ${PROJECT_VERSION} LANGUAGES CXX)

add_executable( ${PROJECT_NAME}
	${CMAKE_CURRENT_LIST_DIR}/calculator_tests.cpp
)
set_target_properties( ${PROJECT_NAME} 
    PROPERTIES 
		DEBUG_POSTFIX "-d"
)
target_include_directories( ${PROJECT_NAME}
	PRIVATE
		${CMAKE_CURRENT_LIST_DIR}/include
)
target_link_libraries( ${PROJECT_NAME}
	PRIVATE
		${TEST_TARGET}
		catch
		fakeit
)

add_test(
	NAME ${PROJECT_NAME} 
	COMMAND ${PROJECT_NAME} --reporter junit --out ${PROJECT_NAME}.xml
)

install(
	FILES ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.xml
	DESTINATION ./code-analysis
)

include(code-coverage)
setup_target_for_coverage(
	TARGET ${TEST_TARGET}
	TEST_RUNNER ${PROJECT_NAME}
)