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

set(CUKE_DISABLE_BOOST_TEST     OFF)
set(CUKE_DISABLE_GTEST          OFF)
set(CUKE_DISABLE_UNIT_TESTS     ON)
set(CUKE_DISABLE_E2E_TESTS      ON)
set(CUKE_ENABLE_EXAMPLES        ON)
set(CUKE_DISABLE_QT             ON)
set(VALGRIND_TESTS              OFF)

add_subdirectory(cucumber-cpp-repo)