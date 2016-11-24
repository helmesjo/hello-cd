#include <catch_with_main.hpp>
#include "calculator.hpp"
#include <iostream>
#include <fstream>
#include <string>
#include "resources.h"
#include <filesystem>
#include "cpplocate\cpplocate.h"

using namespace std::string_literals;
using namespace std::experimental;
using namespace hellocmake_tests;

TEST_CASE("calculator.sum()", "calculator") {
	calculator t;

	auto sum = t.sum(1, 2);

	REQUIRE(sum == 3);
}

TEST_CASE("Read file from test resource", "calculator") {
	const auto exePath = cpplocate::getModulePath();
	auto resourcePath = exePath + "/" + resources::RESOURCE1;
	std::ifstream file(resourcePath, std::fstream::in);

	std::cout << "Current Path: " << resourcePath << std::endl;

	auto string = ""s;
	std::getline(file, string);

	REQUIRE(file.is_open() == true);
	REQUIRE(string == "Tezzzt");
}