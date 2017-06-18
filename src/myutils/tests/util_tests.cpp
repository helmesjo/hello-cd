#include "myutils/util.hpp"

#include <catch_with_main.hpp>
#include <fakeit.hpp>

using namespace fakeit;

TEST_CASE("magic_sum", "util") {
	auto sum = util::magic_sum(1, 2);

	REQUIRE(sum == 3);
}