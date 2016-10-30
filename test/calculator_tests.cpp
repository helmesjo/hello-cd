#include "calculator.hpp"
#include <iostream>
#include <catch_with_main.hpp>

TEST_CASE("calculator.sum()", "Pass valid args") {
	calculator t;

	auto sum = t.sum(1, 2);

	REQUIRE(sum == 5);
}