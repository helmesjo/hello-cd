cmake_minimum_required(VERSION 3.8 FATAL_ERROR)
project(catch VERSION 1.9.4 LANGUAGES CXX)

add_library(${PROJECT_NAME} INTERFACE)

target_include_directories(${PROJECT_NAME} 
    INTERFACE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    	$<INSTALL_INTERFACE:./>
)