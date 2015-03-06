Feature: Filtering documents
  In order to find relevant documents,
  As a user
  I want to be able to filter a list of documents

  Scenario: Filters document by metadata
    Given a collection of documents exist
    Then I can get a list of all documents with matching metadata

  Scenario: Filter document by keyword
    Given a collection of documents exist
    When I search documents by keyword
    Then I see all documents which contain the keywords

  Scenario: Visit a government finder
    Given a government finder exists
    Then I can see the government header
