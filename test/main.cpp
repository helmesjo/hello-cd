#include "test.hpp"
#include <iostream>
#include <catch_with_main.hpp>

TEST_CASE("test.sum()", "Pass valid args") {
	test t;

	auto sum = t.sum(1, 2);

	REQUIRE(sum == 5);
}