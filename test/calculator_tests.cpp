#include <catch_with_main.hpp>
#include "calculator.hpp"
#include <iostream>
#include <fstream>
#include <string>
#include "resources\resources.h"
#include <filesystem>

using namespace std::string_literals;
using namespace std::experimental;
using namespace hellocmake_tests;

TEST_CASE("calculator.sum()", "calculator") {
	calculator t;

	auto sum = t.sum(1, 2);

	REQUIRE(sum == 3);
}

TEST_CASE("Read file from test resource", "calculator") {
	auto workingDir = filesystem::current_path();
	auto exeDir = workingDir.string() + "/Debug/"; // <--- Fix relative paths to exe (need some plugin... This is madness!)
	std::ifstream file(exeDir + resources::RESOURCE1, std::fstream::in);

	std::cout << "Current Path: " << exeDir << std::endl;

	auto string = ""s;
	std::getline(file, string);

	REQUIRE(file.is_open() == true);
	REQUIRE(string == "Tezzzt");
}