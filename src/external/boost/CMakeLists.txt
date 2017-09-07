cmake_minimum_required(VERSION 3.7.1)
project(boost VERSION 1.64.0 LANGUAGES CXX)

include(boost-download)

set( boost_MODULES 
    date_time
    program_options
    regex
    system
    thread
)

set(CLONE_DIR "${CMAKE_CURRENT_BINARY_DIR}/boost-test-dl")
download_boost(
    URL "https://github.com/boostorg/boost.git"
    TAG "boost-${PROJECT_VERSION}"
    CLONE_DIR "${CLONE_DIR}"
    SUBMODULES ${boost_MODULES}
)

#set(REPO_DIR ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}-repo)
#download_repo(
#    URL "${CLONE_DIR}"
#    TAG "boost-${PROJECT_VERSION}"
#    CLONE_DIR ${REPO_DIR}
#)