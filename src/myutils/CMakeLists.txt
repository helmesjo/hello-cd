project(myutils VERSION 0.1 LANGUAGES CXX)

add_library( ${PROJECT_NAME}
	src/util.cpp
)
add_library(
	${CMAKE_PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME}
)
target_include_directories( ${PROJECT_NAME} 
	INTERFACE
    	$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    	$<INSTALL_INTERFACE:include>
    PRIVATE
		include/${PROJECT_NAME}
)

set_target_properties(${PROJECT_NAME} 
	PROPERTIES
    	CXX_STANDARD 14
    	CXX_STANDARD_REQUIRED ON
    	CXX_EXTENSIONS OFF
		DEBUG_POSTFIX "-d"
)

# 'make install' to the correct locations (provided by GNUInstallDirs).
install(
	TARGETS ${PROJECT_NAME}
	EXPORT ${PROJECT_NAME}-targets
    ARCHIVE  DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY  DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME  DESTINATION ${CMAKE_INSTALL_BINDIR} # This is for Windows
)
# Copy along include directory
install(
	DIRECTORY include/
	DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Make project importable from the install directory
install(
	EXPORT ${PROJECT_NAME}-targets
	FILE ${PROJECT_NAME}-config.cmake
	NAMESPACE ${CMAKE_PROJECT_NAME}::
	DESTINATION lib/cmake/${PROJECT_NAME}
)
# Make project importable from build directory
export(
	TARGETS ${PROJECT_NAME} 
	FILE ${PROJECT_NAME}-config.cmake
)

# Setup static analysis
include(code-analysis)
setup_target_for_analysis(
	${PROJECT_NAME}
)

include(tests/CMakeLists.txt)