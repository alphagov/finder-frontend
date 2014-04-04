Feature: Filtering cases
  In order to find relevant cases,
  As a user
  I want to be able to filter a list of cases by case type

  Scenario: Business analyst filters cases by case type
    Given a collection of cases exist
    Then I can get a list of all merger inquiries

  Scenario: Filter cases by keyword
    Given a collection of cases exist
    When I search cases by keyword
    Then I see all cases which contain the keywords
