@wip
Feature: Site search
  In order to find relevant documents,
  As a user
  I want to be able to search a list of documents

  Scenario: When no search terms are entered
    Given no search results exist
    When I search for an empty string
    Then I am able to set search terms

  Scenario: When search terms are entered and filtered by organisation
    Given search results exist
    And the all content finder exists
    When I search for "search-term" from "ministry-of-magic"
    Then I am redirected to the html all content finder results page
    And results are filtered with a facet tag of Ministry of Magic

  Scenario: When search terms are entered and filtered by manual
    Given search results exist
    And the all content finder exists
    When I search for "search-term" in manual "how-to-be-a-wizard"
    Then I am redirected to the html all content finder results page
    And results are filtered with a facet tag of How to be a Wizard

  Scenario: JSON endpoint
    Given search results exist
    And the all content finder exists
    When I search for "search-term" from "ministry-of-magic" on the json endpoint
    Then I am redirected to the json all content finder results page
