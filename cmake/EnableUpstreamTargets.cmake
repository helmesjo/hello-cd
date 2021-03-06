define_property(GLOBAL PROPERTY UPSTREAM_TARGETS
    BRIEF_DOCS "Global list of upstream targets"
    FULL_DOCS "Global list of upstream targets"
)

# Overload add_library to remember all targets manually (checking if target exists is not reliable enough)
macro(add_library)
    _add_library(${ARGV})
    set_property(GLOBAL APPEND PROPERTY UPSTREAM_TARGETS "${ARGV0}")
endmacro()

# Overload find_package to null-op if package is an upstream target (in same build)
# If package is an upstream target, <packagename>_FOUND is set to TRUE
macro(find_package)
    get_property(UPSTREAM_TARGETS GLOBAL PROPERTY UPSTREAM_TARGETS)
    set(target_name "${ARGV0}")
    if(NOT ${target_name} IN_LIST UPSTREAM_TARGETS)
        _find_package(${ARGV})
    else()
        string(CONCAT found "${target_name}" "_FOUND")
        set(${found} TRUE)
    endif()
endmacro()