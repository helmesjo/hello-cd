# language: en
Feature: A Walking Skeleton
  To make sure we always have 
  a buildable & runnable application, 
  we must walk the skeleton.

  Scenario Outline: Add two numbers
    Given I first entered <input_1> into the calculator
    And I then entered <input_2> into the calculator
    When I press sum
    Then the result should be <output> on the screen
    And the project name is also known

  Examples:
    | input_1 | input_2 | output |
    | 20      | 30      | 50     |
    | 2       | 5       | 7      |
    | 0       | 40      | 40     |