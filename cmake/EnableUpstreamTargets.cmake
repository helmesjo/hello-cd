define_property(GLOBAL PROPERTY UPSTREAM_TARGETS
    BRIEF_DOCS "Global list of upstream targets"
    FULL_DOCS "Global list of upstream targets"
)

# Overload add_library to remember all targets manually (checking if target exists is not reliable enough)
macro(add_library)
    _add_library(${ARGV})
    # No need to store aliases
    if(NOT "${ARGV1}" STREQUAL "ALIAS")
        set_property(GLOBAL APPEND PROPERTY UPSTREAM_TARGETS "${ARGV0}")
    endif()
endmacro()

# Overload find_package to null-op if package is an upstream target (in same build)
# If package is an upstream target, <packagename>_FOUND is set to TRUE
macro(find_package)
    get_property(UPSTREAM_TARGETS GLOBAL PROPERTY UPSTREAM_TARGETS)
    if(NOT "${ARGV0}" IN_LIST UPSTREAM_TARGETS)
        _find_package(${ARGV})
    else()
        set("${target_name}_FOUND" TRUE PARENT_SCOPE)
    endif()
endmacro()