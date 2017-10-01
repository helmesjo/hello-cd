cmake_minimum_required(VERSION 3.7.1)
set(boost_VERSION 1.64.0)

include(boost-download)
include(git-download)

set(CLONE_DIR "${CMAKE_CURRENT_BINARY_DIR}/boost-download")
set(REPO_DIR "${CMAKE_CURRENT_LIST_DIR}/boost-repo")
set(boost_URL "https://github.com/boostorg/boost.git")
set(boost_TAG "boost-${boost_VERSION}")

set( boost_MODULES
    boost   # For header-only libs
    date_time
    log     # Adding this explicitly else bcp fails to copy log/config which is required in boost-cmake/libs/log
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
else()
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
        TAG ${boost_TAG}
        CLONE_DIR "${REPO_DIR}"
    )

    # meta-data stored by download_repo assumes we pass the real url, 
    # but since we pass a modified repo, the hash will be wrong so we store it manually
    store_repo_head(
        URL ${boost_URL}
        TAG ${boost_TAG}
        CLONE_DIR "${REPO_DIR}"
    )
endif()

set(boost_cmake_REPO_DIR "${CMAKE_CURRENT_LIST_DIR}/boost-cmake-repo")
download_repo(
    URL "https://github.com/Orphis/boost-cmake.git"
    TAG v${boost_VERSION}
    CLONE_DIR ${boost_cmake_REPO_DIR}
)

set(BOOST_SOURCE "${REPO_DIR}")
add_definitions(-DBOOST_THREAD_USES_DATETIME=1)
add_subdirectory( "${boost_cmake_REPO_DIR}" )