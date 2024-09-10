Feature: All content finder ("site search")
  As a user of GOV.UK
  I want to be able to search across all of GOV.UK
  So I can find the content that meets my needs

  Background:
    Given the all content finder exists
    And the new all content finder UI is enabled

  Scenario: Making a search
    When I search all content for "how to walk silly"
    Then I can see results for my search

  Scenario: Spelling suggestion
    When I search all content for "drving"
    Then I see a "driving" spelling suggestion
