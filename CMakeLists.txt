cmake_minimum_required( VERSION 3.6 )

project("hello_root")

#set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/lib)
#set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/lib)
#set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/modules)

# Add external modules
add_subdirectory(${CMAKE_MODULE_PATH}/catch)

message(${CMAKE_CFG_INTDIR})

# Add projects
add_subdirectory(src)
add_subdirectory(test)

enable_testing()
add_test(${TEST_PROJECT_NAME} ${MAIN_PROJECT_NAME})