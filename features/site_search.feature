Feature: Site search
  In order to find relevant documents,
  As a user
  I want to be able to search a list of documents

  Scenario: When no search terms are entered
    Given no search results exist
    When I search for an empty string
    Then I am able to set search terms

  Scenario: When search terms are entered
    Given search results exist
    When I search for "search-term" from "hm-revenue-customs"
    Then I am able to see the document in the search results
    And I am able to see organisations with abbreviations
    And I am able to see organisations without abbreviations
    And I can see search suggestions
    And I can see the search term
    And Analytics values are sent

  Scenario: When search terms are entered
    Given search results exist
    When I search for "<script>XSS</script>"
    Then the search term is escaped

  Scenario: When an invalid search is entered
    Given no search results exist
    When I search for "search-term"
    Then I can see that no search results were found

  Scenario: Search results for historical governments
    Given search results for multiple governments exists
    When I search for "search-term"
    Then search results for previous known governments are tagged as such

  Scenario: Search results for historical governments
    Given search results for multiple governments exists
    When I search for "search-term"
    Then search results for previous known governments are tagged as such

  Scenario: collapse state of the organisation filter
    Given search results exist
    When I search for "search-term" from "hm-revenue-customs"
    Then Organisations filter should be expanded
    When I search for "search-term"
    Then Organisations filter should not be expanded
    When I search for "search-term" with show organisation flag
    Then Organisations filter should be expanded
    When I search for "search-term" with manuals filter
    Then Organisations filter should not be displayed

  Scenario: Pagination
    Given multiple pages of search results exists
    When I search for "search-term"
    Then I should see a link to the next page
    When I navigate to the next page
    Then I should see a link to the previous page

  Scenario: External urls
    Given external urls exist in the of search results
    When I search for "search-term"
    Then long urls should be truncated
    And links should be schema-less

  Scenario: JSON endpoint
    Given search results exist
    When I search for "search-term" on the json endpoint
    Then I should get a valid JSON response

  Scenario: JSON endpoint when no results
    Given no search results exist
    When I search for "search-term" on the json endpoint
    Then I should get a valid JSON response

  Scenario: Search API is down
    Given the search API returns an error state
    When I search for "search-term"
    Then I should get an error page

  Scenario: Search API refuses parameters
    Given the search API returns an HTTP unprocessable entity error
    When I search with bad parameters
    Then I should get a bad request error
