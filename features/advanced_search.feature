@wip
Feature: Advanced Search
  Scenario: Without content purpose supergroup parameter
    Given a collection of tagged documents
    When I filter by taxon alone
    Then The page is not found

  Scenario: Without taxon parameter
    Given a collection of tagged documents
    When I filter by content purpose supergroup alone
    Then The page is not found

  Scenario: Filters documents by taxon and content purpose supergroup
    Given a collection of tagged documents in supergroup 'news_and_communications'
    When I filter by taxon and by supergroup
    Then I only see documents tagged to the taxon tree within the supergroup
    And The correct metadata is displayed for the search results

  Scenario: Filters documents by taxon, supergroup and dates
    Given a collection of tagged documents with dates in supergroup 'news_and_communications'
    When I filter by taxon, supergroup and dates
    Then I only see documents tagged to the taxon tree within the supergroup
    And the correct metadata is displayed for the dates

  Scenario: Filters documents by taxon, supergroup and subgroups
    Given a collection of tagged documents in supergroup 'news_and_communications' and subgroups 'news,updates_and_alerts'
    When I filter by taxon, supergroup and subgroups
    Then I only see documents tagged to the taxon tree within the supergroup and subgroups
    And The correct metadata is displayed for the search results
