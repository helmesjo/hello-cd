cmake_minimum_required(VERSION 3.7.1)
project(boost_build VERSION 1.64.0 LANGUAGES CXX)

include(boost-build)

set( boost_MODULES 
    date_time
    thread
    system
    regex
    program_options
)

# What to do (in new boost-dependencies.cmake):
# After fetching desired submodules, pass module names & repo-dir (preferably tmp-dir with .gitmodules intact) to get_dependencies(...) in boost-dependencies.cmake.
# This should first pull required submodules for boostdep, build it and run:  .\dist\bin\boostdep.exe --subset <module>
# on each passed module, create a nice formatted list with all required module names.
# Don't want boost-dependencies.cmake to know about git-download.cmake, so these must be run recursively until there are no missing dependencies...

# Needed submodules to build boostdep:
# * tools/build
# * tools/boostdep
# * libs/config
# * libs/filesystem
# * libs/system
# * libs/core
# * libs/type_traits
# * libs/predef
# * libs/assert
# * libs/iterator
# * libs/mpl
# * libs/preprocessor
# * libs/static_assert
# * libs/detail
# * libs/smart_ptr
# * libs/throw_exception
# * libs/io
# * libs/functional
# * libs/range
# * libs/winapi (if on windows)



set(REPO_DIR ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}-repo)
download_boost(
    URL "https://github.com/boostorg/boost.git"
    TAG "boost-${PROJECT_VERSION}"
    CLONE_DIR "${CMAKE_CURRENT_BINARY_DIR}/boost-test-dl"
    SUBMODULES ${boost_MODULES}
)
