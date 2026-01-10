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

  Scenario: Filter document by keyword
    Given a collection of documents exist
    When I search documents by keyword: "keyword searchable"
    Then I see all documents which contain the keywords
    And there is not a zero results message
    And the page title is updated
    And I can see that Google won't index the page

  @javascript
  Scenario: User tries to filter with malicious input
    Given a collection of documents exist
    When I search documents by keyword: "<script>alert(0)</script>"
    Then the page title is updated
    And there should not be an alert
    And there is not a zero results message

  Scenario: Filter document by keyword with q parameter
    Given a collection of documents exist
    When I visit a finder by keyword with q parameter
    Then I see all documents which contain the keywords
    And there is not a zero results message

  Scenario: Visit a government finder
    Given a government finder exists
    Then I can see documents which are marked as being in history mode

  Scenario: Filters document with bad metadata
    Given a collection of documents with bad metadata exist
    Then I can get a list of all documents with good metadata

  Scenario: Visit a finder with dynamic filter
    Given a finder with a dynamic filter exists
    Then I can see filters based on the results
    And filters are wrapped in a progressive disclosure element

  Scenario: Visit a finder with no facets
    Given no results
    When I view the finder with no keywords and no facets
    And filters are not wrapped in a progressive disclosure element

  Scenario: Visit a finder with paginated results
    Given a finder with paginated results exists
    Then I can see pagination
    And there is machine readable information
    And I can see that Google can index the page
    And I can browse to the next page
    And I can see that Google won't index the page
    Then I browse to a huge page number and get an appropriate error

  Scenario: Visit a finder with metadata
    Given a finder with metadata exists
    Then I can see that the finder metadata is present

  Scenario: Visit a finder with metadata with a topic param set
    When I view the aaib reports finder with a topic param set
    Then I can see that the finder metadata is present and inverted
    And the breadcrumbs are outside the main container

  Scenario: Visit a finder with description
    Given a finder with description exists
    Then I can see that the description in the metadata is present

  Scenario: Visit a finder with noindex
    Given a finder with a no_index property exists
    Then I can see that the noindex tag is is present in the metadata

  Scenario: Visit a finder from an organisation
    Given an organisation finder exists
    Then I can see a breadcrumb for home
    And I can see a breadcrumb for all organisations
    And I can see a breadcrumb for the organisation
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
      | Relevance        |
      | Updated (newest) |
      | Updated (oldest) |
    When I view a list of services
    Then I can sort by:
      | A-Z         |
      | Most viewed |
      | Relevance   |

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
  Scenario: Adding keyword filter
    When I view the news and communications finder
    Then I see Updated (newest) order selected
    And I fill in some keywords
    And I press tab key to navigate
    Then I see Relevance order selected

  Scenario: Subscribing to email alerts
    Given a collection of documents exist that can be filtered by checkbox
    When I use a checkbox filter
    Then I can sign up to email alerts for allowed filters

  Scenario: Subscribing to email alerts with disallowed facets
    Given a collection of documents exist that can be filtered by checkbox
    When I use a checkbox filter and another disallowed filter
    Then I can sign up to email alerts for allowed filters

  Scenario: Subscribing to email alerts with missing filters
    Given a collection of documents exist that can be filtered by checkbox
    When I do not select any of the filters on the signup page
    Then I see an error about selecting at least one option

  @javascript
  Scenario: Filter documents by keywords and sort by most relevant
    When I view the news and communications finder
    And I fill in some keywords
    And I sort by most relevant
    Then I see Relevance order selected

  Scenario: Dynamic facets continue to show all options on page reload
    When I view the news and communications finder
    And I select a Person
    And I reload the page
    Then I should see all people in the people facet
    And I should see all organisations in the organisation facet
    And I should see all world locations in the world location facet

  @javascript
  Scenario: Skip to results after inputing some keywords
    When I view the news and communications finder
    And I should not see a "Skip to results" link
    And I fill in some keywords
    And I press tab key to navigate
    Then I should see a "Skip to results" link
    And the page has results region

  @javascript
  Scenario: A Blue Banner should be displayed when navigating from a topic page
    When I view the research and statistics finder with a topic param set
    Then I should see a blue banner

  Scenario: Results should be a landmark to allow screenreaders to jump to it quickly
    When I view the news and communications finder
    Then the page has a landmark to the search results

  Scenario: Email links
    When I view the news and communications finder
    Then I see email and feed sign up links
    And I select a Person
    And I filter the results
    Then I see email and feed sign up links with filters applied

  @javascript
  Scenario: Email links while on mobile
    When I view the news and communications finder
    Then I see only one email and feed sign up link on mobile

  @javascript
  Scenario: Policy papers should have three options
    When I view the policy papers and consultations finder
    And I select some document types
    Then I should see results for scoped by the selected document type

  Scenario: Choosing between document types with a research and statistics facet
    When I view the research and statistics finder
    Then I should see all research and statistics
    And I select upcoming statistics
    And I click filter results
    Then I should see upcoming statistics
    And I see Release date (soonest) order selected
    And I can sort by:
      | Most viewed            |
      | Relevance              |
      | Release date (latest)  |
      | Release date (soonest) |
    And I should not see an upcoming statistics facet tag
    Then I select published statistics
    And I click filter results
    Then I see Updated (newest) order selected
    And I can sort by:
      | Most viewed           |
      | Relevance             |
      | Updated (newest)      |
      | Updated (oldest)      |

  @javascript
  Scenario: Choosing between document types research and statistics - no facet tag; javascript version
    When I view the research and statistics finder
    And I select upcoming statistics
    Then I should see upcoming statistics
    And I see Release date (soonest) order selected
    And I can sort by:
      | Most viewed            |
      | Relevance              |
      | Release date (latest)  |
      | Release date (soonest) |
    And I should not see an upcoming statistics facet tag
    Then I select published statistics
    Then I see Updated (newest) order selected
    And I can sort by:
      | Most viewed           |
      | Relevance             |
      | Updated (newest)      |
      | Updated (oldest)      |

  Scenario: Atom Feed
    When I view the research and statistics finder
    And I click on the atom feed link
    Then I see the atom feed
