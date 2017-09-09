cmake_minimum_required(VERSION 3.7.1)
project(boost VERSION 1.64.0 LANGUAGES CXX)

include(boost-download)
include(git-download)

set(CLONE_DIR "${CMAKE_CURRENT_BINARY_DIR}/boost-download")
set(REPO_DIR "${PROJECT_SOURCE_DIR}/${PROJECT_NAME}-repo")
set(boost_URL "https://github.com/boostorg/boost.git")
set(boost_TAG "boost-${PROJECT_VERSION}")

set( boost_MODULES
    build
    date_time
    program_options
    regex
    system
    thread
)

# Skip download if up-to-date
check_if_up_to_date(
    URL ${boost_URL}
    TAG ${boost_TAG}
    CLONE_DIR "${REPO_DIR}"
    OUTPUT_VARIABLE IS_UP_TO_DATE
)
if(IS_UP_TO_DATE)
    message("Already up-to-date with branch '${boost_TAG}' on ${boost_URL}\n\tSkipping download.")
    return()
endif()

# Download a stripped down version of boost, containing only specified modules & dependencies
download_boost(
    URL ${boost_URL}
    TAG ${boost_TAG}
    CLONE_DIR "${CLONE_DIR}"
    SUBMODULES ${boost_MODULES}
)

# "Download" tmp repo & merge with subtree
download_repo(
    URL "${CLONE_DIR}"
    TAG "boost-${PROJECT_VERSION}"
    CLONE_DIR "${REPO_DIR}"
)

# meta-data stored by download_repo assumes we pass the real url, 
# but since we pass a modified repo, the hash will be wrong so we store it manually
store_repo_head(
    URL ${boost_URL}
    TAG ${boost_TAG}
    CLONE_DIR "${REPO_DIR}"
)
