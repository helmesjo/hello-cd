#include <gtest/gtest.h>
#include <cucumber-cpp/autodetect.hpp>

#include <mylib/calculator.hpp>

using cucumber::ScenarioScope;

struct CalcCtx {
    calculator calc;
    int first;
    int second;
    int result;
};

GIVEN("^I first entered (\\d+) into the calculator$") {
    REGEX_PARAM(int, n);
    ScenarioScope<CalcCtx> context;

    context->first = n;
}

WHEN("^I then entered (\\d+) into the calculator$") {
    REGEX_PARAM(int, n);
    ScenarioScope<CalcCtx> context;

    context->second = n;
}

WHEN("^I press sum") {
    ScenarioScope<CalcCtx> context;

    context->result = context->calc.sum(context->first, context->second);
}

THEN("^the result should be (.*) on the screen$") {
    REGEX_PARAM(int, expected);
    ScenarioScope<CalcCtx> context;

    EXPECT_EQ(expected, context->result);
}