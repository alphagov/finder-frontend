Feature: Site search
  In order to find relevant documents,
  As a user
  I want to be able to search a list of documents

  Background:
    Given the search page exists
    And the all content finder exists
    And the new all content finder UI is disabled

  Scenario: When no search terms are entered
    When I search for an empty string
    Then I am able to set search terms

  Scenario: When search terms are entered and filtered by organisation
    When I search for "search-term" from "ministry-of-magic"
    Then I am redirected to the html all content finder results page
    And results are filtered with a facet tag of Ministry of Magic

  Scenario: When search terms are entered and filtered by manual
    When I search for "search-term" in manual "how-to-be-a-wizard"
    Then I am redirected to the html all content finder results page
    And results are filtered with a facet tag of How to be a Wizard

  Scenario: JSON endpoint
    When I search for "search-term" from "ministry-of-magic" on the json endpoint
    Then I am redirected to the json all content finder results page

  Scenario: Spelling suggestion
    When I search for "drving"
    Then I see a "driving" spelling suggestion
