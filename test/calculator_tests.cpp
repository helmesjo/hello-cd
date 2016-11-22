#include <catch_with_main.hpp>
#include "calculator.hpp"
#include <iostream>
#include <fstream>
#include <string>
#include "resources.h"

using namespace std::string_literals;

TEST_CASE("sum()", "calculator") {
	calculator t;

	auto sum = t.sum(1, 2);

	REQUIRE(sum == 3);
}

TEST_CASE("Read file from resource", "calculator") {
	std::ifstream file(resources::RESOURCE2);

	auto string = ""s;
	std::getline(file, string);

	REQUIRE(string == "First line");
}