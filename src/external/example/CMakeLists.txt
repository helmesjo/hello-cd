cmake_minimum_required(VERSION 3.2.2)
project(example VERSION 1.9.5 LANGUAGES CXX)

include(git-download)

set(REPO_DIR ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}-repo)
download_repo(
    URL "https://github.com/joonty/example.git"
    TAG addedSubmodule
    CLONE_DIR ${REPO_DIR}
    SUBMODULES "doctrine"
)

add_library(${PROJECT_NAME} INTERFACE)