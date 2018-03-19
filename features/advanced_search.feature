Feature: Advanced Search
  Scenario: Filters documents by taxon path
    Given a collection of tagged documents
    When I search by taxon
    Then I only see documents tagged to the taxon

  Scenario: Filters documents by taxon and content purpose supergroup
    Given a collection of tagged documents in supergroup 'news_and_communications'
    When I search by taxon and by supergroup
    Then I only see documents tagged to the taxon within the supergroup

  Scenario: Filters documents by taxon, supergroup and subgroups
    Given a collection of tagged documents in supergroup 'news_and_communications' and subgroups 'news,updates_and_alerts'
    When I search by taxon, supergroup and subgroups
    Then I only see documents tagged to the taxon within the supergroup and subgroups
