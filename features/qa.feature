Feature: QA
  In order to find tailored documents,
  As a user
  I want to be able to answer questions to filter by my interests

  Background:
    Given a QA finder exists
    When I visit the QA page
    Then I should see the first question

    Scenario: Answering a single option question
      Given I am answering a single answer question
      Then I should see a collection of radio buttons
      When I select a radio button
      When I select a radio button
      When I submit my answer
      Then my options are persisted as url params

    Scenario: Answering a single_wrapped option question
      Given I am answering a single_wrapped answer question
      Then I should see a collection of radio buttons
      When I select a radio button
      Then I should see a collection of checkboxes
      When I select multiple checkboxes
      When I submit my answer
      Then my options are persisted as url params

    Scenario: Answering a multiple option question
      Given I am answering a multiple answer question
      Then I should see a collection of checkboxes
      When I select multiple checkboxes
      When I submit my answer
      Then my options are persisted as url params

    Scenario: Answering multiple questions
      Given I am answering a single answer question
      Then I should see a collection of radio buttons
      When I select a radio button
      When I submit my answer
      Then I should see a collection of checkboxes
      When I select multiple checkboxes
      When I submit my answer
      Then my options are persisted as url params

    Scenario: Skipping a question
      When I select skip this question
      Then no options are persisted

    Scenario: Answering the final question
      Given I am answering the final question
      When I submit my answer
      Then I am redirected to the finder results page
