Feature: Email alert signup
  In order to be notified of published documents
  As a user
  I want to be sign up for email notifications

  Scenario: Signing up to filtered notifications
    Given I sign up to notifications for a filtered set of Medical Safety Alerts
    Then I should be subscribed to those filtered notifications
