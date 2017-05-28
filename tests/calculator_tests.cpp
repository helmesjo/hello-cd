#include <catch_with_main.hpp>
#include <catch/fakeit.hpp>
#include <cpplocate/cpplocate.h>
#include <iostream>
#include <fstream>
#include <string>
#include "calculator.hpp"
#include "resources.h"

using namespace hellocmake_tests;
using namespace fakeit;

struct SomeInterface
{
	virtual int dummyMethod() = 0;
};

TEST_CASE("calculator.sum()", "calculator") {
	calculator t;

	auto sum = t.sum(1, 2);

	REQUIRE(sum == 3);
}

TEST_CASE("Create mock", "lib_fakeit")
{
	auto mock = Mock<SomeInterface>();
	When(Method(mock, dummyMethod)).Return(1);
	
	auto& fake = mock.get();
	REQUIRE(fake.dummyMethod() == 1);
}

TEST_CASE("Read file from test resource", "lib_cpplocate") {
	const auto exePath = cpplocate::getModulePath();
	auto resourcePath = exePath + "/" + resources::RESOURCE1;
	std::ifstream file(resourcePath, std::fstream::in);

	std::cout << "Current Path: " << resourcePath << std::endl;

	std::string string;
	std::getline(file, string);

	REQUIRE(file.is_open() == true);
	REQUIRE(string == "Tezzzt");
}