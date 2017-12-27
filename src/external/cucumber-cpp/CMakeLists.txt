cmake_minimum_required(VERSION 3.2.2)
set(cucumber_VERSION 0.4)

include(git-download)

set(REPO_DIR "${CMAKE_CURRENT_LIST_DIR}/cucumber-cpp-repo")
download_repo(
    URL "https://github.com/cucumber/cucumber-cpp.git"
    TAG v${cucumber_VERSION}
    CLONE_DIR ${REPO_DIR}
    SUBMODULES features/cucumber-tck
)

find_package(Boost REQUIRED
    COMPONENTS
        thread 
        system 
        regex 
        date_time 
        program_options 
        filesystem    
)
if(NOT MSVC)
    find_package(Threads QUIET)
endif()

add_definitions(-DBOOST_THREAD_USES_DATETIME=1)

# Setup expected variables & includes, since we bypass the root cmake-script (it is absolute poison)
set(CUKE_INCLUDE_DIR "${REPO_DIR}/include")
set(CUKE_DEPENDENCIES
    ${CMAKE_THREAD_LIBS_INIT}
    Boost::boost 
    Boost::thread 
    Boost::system 
    Boost::regex 
    Boost::date_time 
    Boost::program_options 
    Boost::filesystem
    gtest
)
set(CUKE_SOURCE_DIR "${REPO_DIR}/src")

include_directories(${CUKE_INCLUDE_DIR})
add_subdirectory("${CUKE_SOURCE_DIR}" EXCLUDE_FROM_ALL)

# Manually add gtest driver
set_property(
    TARGET cucumber-cpp 
    APPEND PROPERTY SOURCES
        $<BUILD_INTERFACE:${CUKE_SOURCE_DIR}/drivers/GTestDriver.cpp>
)

# Since cucumber-cpp isn't aware of "modern" cmake, do it for them so downstream targets just link it &
# all includes are automagically setup (as per cmake-convention since 5 years back)

# Set required link targets to build cucumber-cpp
set_property(
    TARGET cucumber-cpp 
    APPEND PROPERTY LINK_LIBRARIES
        ${CUKE_DEPENDENCIES}
)
set_property(
    TARGET cucumber-cpp-nomain
    APPEND PROPERTY LINK_LIBRARIES
        ${CUKE_DEPENDENCIES}
)

# Expose required link targets for consumers
set_property(
    TARGET cucumber-cpp 
    APPEND PROPERTY INTERFACE_LINK_LIBRARIES
        ${CUKE_DEPENDENCIES}
)
set_property(
    TARGET cucumber-cpp-nomain
    APPEND PROPERTY INTERFACE_LINK_LIBRARIES
        ${CUKE_DEPENDENCIES}
)

# Expose required include directories for consumers
set_property(
    TARGET cucumber-cpp 
    APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES
        $<BUILD_INTERFACE:${CUKE_INCLUDE_DIR}>
)
set_property(TARGET cucumber-cpp-nomain
    APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES
        $<BUILD_INTERFACE:${CUKE_INCLUDE_DIR}>
)