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
    And I can see how many results there are

  Scenario: Filtering results
    When I search all content for "how to walk silly"
    And I open the filter panel
    Then I can see a filter section for every visible facet on the all content finder

  Scenario: Changing the sort order of a search
    When I search all content for "dark gray all alone"
    And I open the filter panel
    And I open the "Sort by" filter section
    And I select the "Updated (oldest)" option
    And I apply the filters
    Then I can see sorted results

  Scenario: Spelling suggestion
    When I search all content for "drving"
    Then I see a "driving" spelling suggestion
