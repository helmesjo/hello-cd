cmake_minimum_required( VERSION 2.8.7 )

project("hello_root")

# Add compile flags
set(DEBUG_FLAGS "-std=c++11 -g -O1 -Wall -Wextra -Werror -pedantic")
set(RELEASE_FLAGS "-std=c++11 -O3 -Wall -Wextra -Werror -pedantic")

set(CMAKE_CXX_FLAGS ${RELEASE_FLAGS})
set(CMAKE_CXX_FLAGS_DEBUG ${DEBUG_FLAGS})
set(CMAKE_CONFIGURATION_TYPES Debug Release)

# Add modules
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/modules)
add_subdirectory(${CMAKE_MODULE_PATH}/catch)

message(${CMAKE_CFG_INTDIR})

# Add projects
add_subdirectory(src)
add_subdirectory(test)

enable_testing()
add_test(NAME ${TEST_PROJECT_NAME} COMMAND ${TEST_PROJECT_NAME})