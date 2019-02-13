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

  Scenario: Filter documents with checkbox
    Given a collection of documents exist that can be filtered by checkbox
    When I use a checkbox filter
    Then I only see documents that match the checkbox filter
    And I see the facet tag

  Scenario: A finder with a checkbox facet has tracking
    Given a collection of documents exist that can be filtered by checkbox
    Then The checkbox has the correct tracking data

  Scenario: Filter document by keyword
    Given a collection of documents exist
    When I search documents by keyword
    Then I see all documents which contain the keywords

  Scenario: Hiding keyword search
    Given no results
    When I view the finder with no keywords and no facets
    Then I see no results
    And there is no keyword search box

  Scenario: Visit a government finder
    Given a government finder exists
    Then I can see the government header
    And I can see documents which are marked as being in history mode

  Scenario: Filters document with bad metadata
    Given a collection of documents with bad metadata exist
    Then I can get a list of all documents with good metadata

  Scenario: Visit a finder with dynamic filter
    Given a finder with a dynamic filter exists
    Then I can see filters based on the results

  Scenario: Visit a finder autocomplete
    Given a finder with autocomplete exists
    Then I can filter based on the results

  Scenario: Visit a finder with paginated results
    Given a finder with paginated results exists
    Then I can see pagination
    And I can see that Google can index the page
    And I can browse to the next page
    And I can see that Google won't index the page
    Then I browse to a huge page number and get an appropriate error

  Scenario: Visit a finder with description
    Given a finder with description exists
    Then I can see that the description in the metadata is present

  Scenario: Link tracking
    Given a government finder exists
    Then the links on the page have tracking attributes

  Scenario: Visit a finder from an organisation
    Given an organisation finder exists
    Then I can see a breadcrumb for home
    And I can see a breadcrumb for all organisations
    And I can see a breadcrumb for the organisation
    And I can see a breadcrumb that not a link for the finder
    And I sort by most viewed
    And I filter the results
    Then I can see a breadcrumb for the organisation

  Scenario: Visit a finder from an organisation handling breadcrumb failures
    Given an organisation finder exists but a bad breadcrumb path is given
    Then I can see a breadcrumb for home
    And no breadcrumb for all organisations

  Scenario: Visit a finder not from an organisation
    Given a finder tagged to the topic taxonomy
    Then I can see taxonomy breadcrumbs
    And I can see a breadcrumb for home

  Scenario: Sorting options
    When I view a list of news and communications
    Then I can sort by:
      | Most viewed      |
      | Relevance        |
      | Updated (newest) |
      | Updated (oldest) |
    When I view a list of services
    Then I can sort by:
      | A-Z         |
      | Most viewed |
      | Relevance   |

  @javascript
  Scenario: Live sorting options
    When I view a list of news and communications
    Then I can sort by:
      | Most viewed      |
      | Updated (newest) |
      | Updated (oldest) |
    When I view a list of services
    Then I can sort by:
      | A-Z         |
      | Most viewed |

  Scenario: Sorting news and communications by most viewed
    When I view a list of news and communications
    And I sort by most viewed
    And I filter the results
    Then I see the most viewed articles first

  @javascript
  Scenario: Live sorting news and communications by most viewed
    When I view a list of news and communications
    And I sort by most viewed
    Then I see the most viewed articles first

  Scenario: Live sorting services A-Z
    When I view a list of services
    And I sort by A-Z
    And I filter the results
    Then I see services in alphabetical order

  @javascript
  Scenario: Sorting services A-Z
    When I view a list of services
    And I sort by A-Z
    Then I see services in alphabetical order

  @javascript
  Scenario Outline: Removing checkbox filter
    When I view the news and communications finder
    And I click button <filter> and select facet <facet>
    And I click the <facet> remove control
    Then The <checkbox_element> checkbox in deselected
    Examples:
      | facet              | filter           | checkbox_element                |
      | Ministry of Magic  | "Organisation"   | organisations-ministry-of-magic |
      | Harry Potter       | "Person"         | people-harry-potter             |
      | Azkaban            | "World location" | world_locations-azkaban         |

  @javascript
  Scenario: Removing keyword filter
    When I view the news and communications finder
    And I fill in some keywords
    And I click the Keyword1 remove control
    Then The keyword textbox only contains Keyword2

  Scenario: Subscribing to email alerts
    Given a collection of documents exist that can be filtered by checkbox
    When I use a checkbox filter
    Then I can sign up to email alerts for allowed filters

  Scenario: Subscribing to email alerts with disallowed facets
    Given a collection of documents exist that can be filtered by checkbox
    When I use a checkbox filter and another disallowed filter
    Then I can sign up to email alerts for allowed filters

  @javascript
  Scenario: Filter documents by keywords and sort by most relevant
    When I view the news and communications finder
    And I fill in some keywords
    And I sort by most relevant
    Then I see most relevant order selected

  Scenario: Group documents by facets
    When I view the business readiness finder
    Then I should see results in the default group

  @javascript
  Scenario: Filter documents and group by facets
    When I view the business readiness finder
    And I click button "Sector / Business Area" and select facet Aerospace
    Then I see results grouped by primary facet value
