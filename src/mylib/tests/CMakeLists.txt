# Remember name of project we are testing
set(TEST_TARGET ${PROJECT_NAME})
project(${TEST_TARGET}_tests VERSION ${PROJECT_VERSION} LANGUAGES CXX)

include(testing)
add_unit_test(
	TEST_TARGET ${TEST_TARGET}
	TEST_NAME ${PROJECT_NAME}
	SOURCES "tests/calculator_tests.cpp"
	INCLUDE_DIRS "tests/include"
)

include(code-coverage)
setup_target_for_coverage(
	TARGET ${TEST_TARGET}
	TEST_RUNNER ${PROJECT_NAME}
)