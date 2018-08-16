#include "myutils/util.hpp"

#include <catch.hpp>
#include <fakeit.hpp>

using namespace fakeit;

TEST_CASE("magic_sum", "util") {
	auto sum = util::magic_sum(1, 2);

	REQUIRE(sum == 3);
}