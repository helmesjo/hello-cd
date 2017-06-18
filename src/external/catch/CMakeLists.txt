cmake_minimum_required(VERSION 3.2.2)
project(catch VERSION 1.9.5 LANGUAGES CXX)

include(git-download)

set(REPO_DIR ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}-repo)
download_repo(
    DO_PULL OFF
    URL "https://github.com/philsquared/Catch.git"
    TAG v${PROJECT_VERSION}
    CLONE_DIR ${REPO_DIR}
)

add_library(${PROJECT_NAME} INTERFACE)

target_include_directories(${PROJECT_NAME} 
    INTERFACE
        $<BUILD_INTERFACE:${REPO_DIR}/include>
)