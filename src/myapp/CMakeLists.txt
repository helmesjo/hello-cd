project(myapp VERSION 0.1 LANGUAGES CXX)

add_executable(${PROJECT_NAME}
    src/main.cpp
)
set_target_properties(${PROJECT_NAME} 
    PROPERTIES DEBUG_POSTFIX "-d"
)
target_link_libraries(${PROJECT_NAME}
    mylib
)