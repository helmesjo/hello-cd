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

set(CUKE_DISABLE_GTEST ON)
set(CUKE_DISABLE_BOOST_TEST ON)

add_subdirectory(cucumber-cpp-repo)