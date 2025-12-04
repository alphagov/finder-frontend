Feature: All content finder ("site search")
  As a user of GOV.UK
  I want to be able to search across all of GOV.UK
  So I can find the content that meets my needs

  Background:
    Given the all content finder exists
    And the search page exists

  Scenario: Making a search
    When I search all content for "how to walk silly"
    Then I can see results for my search
    And I can see how many results there are
    And the GA4 ecommerce tracking tags are present
    And I can see a breadcrumb for home
    And no breadcrumb for all organisations

  Scenario: Making a search with a hidden clearable filter
    When I search for "search-term" with a hidden clearable manual filter
    And I change my search term to "search-term-updated" and submit
    Then my search is still filtered by manual

  Scenario: Filtering results
    When I search all content for "how to walk silly"
    And I open the filter panel
    Then I can see a filter section for every visible facet on the all content finder

  @javascript
  Scenario: Making a search with filters
    When I search all content for "chandeliers flickering"
    And I open the filter panel
    And I open the "Topic" filter section
    And I select "Work" as the Topic
    And I select "Payroll" as the Subtopic
    And I open the "Type" filter section
    And I check the "Services" option
    And I check the "Research and statistics" option
    And I open the "Date" filter section
    And I enter "1989" for "Year" under "Updated after"
    And I enter "1989" for "Year" under "Updated before"
    And I enter "12" for "Month" under "Updated before"
    And I enter "13" for "Day" under "Updated before"
    And I apply the filters
    Then I can see filtered results
    And the filter panel shows status text for each section

  Scenario: Changing the sort order of a search
    When I search all content for "dark gray all alone"
    And I open the filter panel
    And I open the "Sort by" filter section
    And I select the "Updated (oldest)" option
    And I apply the filters
    Then I can see sorted results

  Scenario: Removing a filter
    When I search all content for "chandeliers flickering"
    And I open the filter panel
    And I open the "Topic" filter section
    And I select "Work" as the Topic
    And I select "Payroll" as the Subtopic
    And I apply the filters
    And I click on the "Subtopic: Payroll" filter tag
    Then the "Subtopic: Payroll" filter has been removed

  @javascript
  Scenario: Entering an incorrect date
    When I search all content for "chandeliers flickering"
    And I open the filter panel
    And I open the "Date" filter section
    And I enter "-1" for "Year" under "Updated before"
    And I apply the filters
    Then the filter panel is open by default
    And I can see an error message "Enter a date"

  Scenario: Spelling suggestion
    When I search all content for "drving"
    Then I see a "driving" spelling suggestion

  Scenario: Search with an organisation (parent) finder
    When I search all content with a parent for "search-term"
    And I open the filter panel
    And I open the "Sort by" filter section
    And I select the "Updated (newest)" option
    And I apply the filters
    Then I can see a breadcrumb for home
    And I can see a breadcrumb for all organisations
    And I can see a breadcrumb for the organisation

  Scenario: Legacy search page
    When I search for "drving" on the legacy search page
    Then I am redirected to the html all content finder results page

  Scenario: Legacy JSON endpoint
    When I search for "search-term" from "ministry-of-magic" on the legacy json endpoint
    Then I am redirected to the json all content finder results page
