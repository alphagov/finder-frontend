Feature: Analytics
  In order to improve search performance
  As a developer
  I want to be able to track user behaviour

  @javascript
  Scenario: Ecommerce tracking
    When I view the all content finder
    Then the ecommerce tracking tags are present

  Scenario: Link tracking
    Given a government finder exists
    Then the links on the page have tracking attributes
