SET(JSON_SPIRIT_SRCS
json_spirit_reader.cpp
json_spirit_value.cpp
json_spirit_writer.cpp)

FIND_PACKAGE(Boost 1.34 QUIET)

ADD_LIBRARY(json_spirit STATIC ${JSON_SPIRIT_SRCS})
target_link_libraries(json_spirit Boost::boost)
