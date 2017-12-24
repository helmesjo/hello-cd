cmake_minimum_required(VERSION 3.2.2)
project(googletest VERSION 1.8.0 LANGUAGES CXX)

include(git-download)

set(REPO_DIR "${PROJECT_SOURCE_DIR}/${PROJECT_NAME}-repo")
download_repo(
    URL "https://github.com/google/googletest.git"
    TAG release-${PROJECT_VERSION}
    CLONE_DIR "${REPO_DIR}"
)

# To fix build-warnings in 1.8.0. Try to remove when upgrading.
add_definitions(
    -DGTEST_HAS_TR1_TUPLE=0
    -DGTEST_HAS_STD_TUPLE=1
    -D_SILENCE_TR1_NAMESPACE_DEPRECATION_WARNING=1
    -D_SCL_SECURE_NO_WARNINGS
)

# Enabling this option will make gtest link the runtimes dynamically too, and match the project in which it is included.
# See: https://github.com/google/googletest/blob/master/googletest/README.md#visual-studio-dynamic-vs-static-runtimes
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
add_subdirectory("${REPO_DIR}" EXCLUDE_FROM_ALL)