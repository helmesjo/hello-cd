cmake_minimum_required(VERSION 3.2.2)
project(googletest VERSION 1.8.0 LANGUAGES CXX)

include(git-download)

set(REPO_DIR ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}-repo)
download_repo(
    URL "https://github.com/google/googletest.git"
    TAG release-${PROJECT_VERSION}
    CLONE_DIR ${REPO_DIR}
)

# Prevent overriding the parent project's compiler/linker
# settings on Windows
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
add_subdirectory("${REPO_DIR}")