project(myapp VERSION 0.1 LANGUAGES CXX)

find_package(mylib QUIET)

add_executable(${PROJECT_NAME}
    src/main.cpp
)
set_target_properties(${PROJECT_NAME} 
    PROPERTIES 
        DEBUG_POSTFIX "-d"
)
target_link_libraries(${PROJECT_NAME}
    PUBLIC
        ${CMAKE_PROJECT_NAME}::mylib
)

# 'make install' to the correct locations (provided by GNUInstallDirs).
install(
	TARGETS ${PROJECT_NAME}
    RUNTIME  DESTINATION ${CMAKE_INSTALL_BINDIR}
)