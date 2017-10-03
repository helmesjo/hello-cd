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

set(CUKE_USE_STATIC_BOOST OFF CACHE BOOL "")
set(CUKE_USE_STATIC_GTEST OFF CACHE BOOL "")

set(CUKE_DISABLE_BOOST_TEST ON CACHE BOOL "")
set(CUKE_DISABLE_GTEST ON CACHE BOOL "")
set(CUKE_DISABLE_UNIT_TESTS ON CACHE BOOL "")
set(CUKE_DISABLE_E2E_TESTS ON CACHE BOOL "")
set(CUKE_ENABLE_EXAMPLES OFF CACHE BOOL "")
set(VALGRIND_TESTS OFF CACHE BOOL "")

add_definitions(-DBOOST_THREAD_USES_DATETIME=1)
add_subdirectory(cucumber-cpp-repo)