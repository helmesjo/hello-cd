#include <gtest/gtest.h>
#include <cucumber-cpp/autodetect.hpp>

#include <mylib/calculator.hpp>

using cucumber::ScenarioScope;

struct CalcCtx {
    calculator calc;
    double first;
    double second;
    double result;
};

GIVEN("^I have entered (\\d+) into the calculator$") {
    REGEX_PARAM(double, n);
    ScenarioScope<CalcCtx> context;

    context->first = n;
    context->second = n;
}

WHEN("^I press add") {
    ScenarioScope<CalcCtx> context;

    context->result = context->calc.sum(context->first, context->second);
}

WHEN("^I press divide") {
    ScenarioScope<CalcCtx> context;

    //context->result = context->calc.divide();
}

THEN("^the result should be (.*) on the screen$") {
    REGEX_PARAM(double, expected);
    ScenarioScope<CalcCtx> context;

    EXPECT_EQ(expected, context->result);
}