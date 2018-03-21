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
    Then I only see documents tagged to the taxon within the supergroup

  Scenario: Filters documents by taxon, supergroup and subgroups
    Given a collection of tagged documents in supergroup 'news_and_communications' and subgroups 'news,updates_and_alerts'
    When I filter by taxon, supergroup and subgroups
    Then I only see documents tagged to the taxon within the supergroup and subgroups
