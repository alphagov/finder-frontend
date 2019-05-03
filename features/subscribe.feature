Feature: Subscribe
  In order to keep up to date with content changes,
  As a user
  I want to be able to subscribe to email updates easily from the finder

  Scenario: Default Finder behaviour - no additional params
    Given I visit the CMA finder email screen
    When I choose an appropriate option from the screen
    And I click "Create subscription"
    Then I should be redirected to "/email/subscriptions/new?topic_id=cma-cases-with-the-following-case-type-competition-disqualification-2"

  Scenario: Business Finder with default_frequency parameter
    Given I visit the business finder email screen
    When I click the "Create subscription" button
    Then I should be redirected to "/email/subscriptions/new?topic_id=find-eu-exit-guidance-for-your-business-appear-in-find-eu-exit-guidance-business-finder&default_frequency=daily"

  # Scenario: Current CMA Finder behaviour
  #   Given I visit "/cma-cases/email-signup"
  #   And I click "Competition disqualification" in the facet options
  #   When I click "Create subscription"
  #   Then I should be redirected to "/email/subscriptions/new?topic_id=cma-cases-with-the-following-case-type-competition-disqualification-2"

  # Scenario: Business Finder with default_frequency parameter
  #   Given I visit "find-eu-exit-guidance-business/email-signup"
  #   When I click "Create subscription"
  #   Then I should be redirected to "/email/subscriptions/new?topic_id=find-eu-exit-guidance-for-your-business-appear-in-find-eu-exit-guidance-business-finder&default_frequency=daily"
