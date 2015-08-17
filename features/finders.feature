Feature: Filtering documents
  In order to find relevant documents,
  As a user
  I want to be able to filter a list of documents

  Scenario: Filters document by metadata
    Given a collection of documents exist
    Then I can get a list of all documents with matching metadata

  Scenario: Filter documents by date
    Given a collection of documents that can be filtered by dates
    When I use a date filter
    Then I only see documents with matching dates

  Scenario: Filter document by keyword
    Given a collection of documents exist
    When I search documents by keyword
    Then I see all documents which contain the keywords

  Scenario: Visit a government finder
    Given a government finder exists
    Then I can see the government header
    And I can see documents which are marked as being in history mode

  Scenario: Visit a policy finder
    Given a policy finder exists
    Then I can see the government header
    And I can see documents which are marked as being in history mode
    And I can see documents which have government metadata

  Scenario: Filters document with bad metadata
    Given a collection of documents with bad metadata exist
    Then I can get a list of all documents with good metadata

  Scenario: Visit a finder with dynamic filter
    Given a finder with a dynamic filter exists
    Then I can see filters based on the results

  Scenario: Visit a finder with paginated results
    Given a finder with paginated results exists
    Then I can see pagination
    And I can browse to the next page

  Scenario: Visit a finder with description
    Given a finder with description exists
    Then I can see that the description in the metadata is present
