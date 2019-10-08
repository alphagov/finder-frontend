Feature: Analytics
  In order to improve search performance
  As a developer
  I want to be able to track user behaviour

  @javascript
  Scenario: eCommerce tracking
    When I view the all content finder
    Then the ecommerce tracking tags are present
    And I search for lunch
    And I submit the form
    Then the data-search-query has been updated to lunch

@javascript
  Scenario: Zero results sends eCommerce tracking
    When I view the all content finder
    And I search for superted
    And I submit the form
    Then the data-ecommerce-content-id has been updated to 99999999-9999-9999-9999-999999999999

  Scenario: Link tracking
    Given a government finder exists
    Then the links on the page have tracking attributes
