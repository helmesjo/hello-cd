#include "test.hpp"
#include <iostream>

int main() 
{
	test t;
	auto val = t.sum(1, 2);

	auto success = (val == 3);

	std::cout << "Success: " << success << std::endl;

	return 0;
}