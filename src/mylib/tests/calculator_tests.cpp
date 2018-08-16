#include "calculator_tests.hpp"
#include "mylib/calculator.hpp"

#include <catch.hpp>
#include <fakeit.hpp>

using namespace fakeit;

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