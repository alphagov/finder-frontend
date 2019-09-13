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
    And there is not a zero results message
    And the page title is updated
    And I can see that Google won't index the page

  Scenario: Filter document by keyword with q parameter
    Given a collection of documents exist
    When I visit a finder by keyword with q parameter
    Then I see all documents which contain the keywords
    And there is not a zero results message

  Scenario: Hiding keyword search
    Given no results
    When I view the finder with no keywords and no facets
    Then I see no results
    And there is no keyword search box
    And there is a zero results message

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

  @javascript
  Scenario: Pagination is removed when there are no results
    Given a finder with paginated results exists
    And I visit the benefits-reform page
    Then I should see results and pagination
    When I fill in a keyword that should match no results
    Then the results and pagination should be removed
    And I click the xxxxxxxxxxxxxxYYYYYYYYYYYxxxxxxxxxxxxxxx remove control
    Then I should see results and pagination

  Scenario: Visit a finder with metadata
    Given a finder with metadata exists
    Then I can see that the finder metadata is present

  Scenario: Visit a finder with metadata with a topic param set
    When I view the aaib reports finder with a topic param set
    Then I can see that the finder metadata is present and inverted

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
    And I can see a breadcrumb that not a link for the finder
    And I sort by most viewed
    And I filter the results
    Then I can see a breadcrumb for the organisation

  Scenario: Visit a finder from an organisation handling breadcrumb failures
    Given an organisation finder exists but a bad breadcrumb path is given
    Then I can see a breadcrumb for home
    And no breadcrumb for all organisations

  Scenario: Business readiness finder has taxon
    When I view the business readiness finder
    Then I can see Brexit taxonomy breadcrumbs

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
    When I view the business readiness finder
    Then I can sort by:
      | Topic         |
      | Most viewed   |
      | Relevance     |
      | Most recent   |
      | A to Z        |

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
  Scenario: Removing keyword filter
    When I view the news and communications finder
    Then I see Updated (newest) order selected
    And I fill in some keywords
    Then I see Relevance order selected
    And the page title contains both keywords
    And I click the Keyword1 remove control
    Then The keyword textbox only contains Keyword2
    And I see Relevance order selected
    And the page title contains only Keyword2
    And I click the Keyword2 remove control
    Then The keyword textbox is empty
    And I see Updated (newest) order selected
    And the page title contains no keywords

  @javascript
  Scenario: Adding keyword filter
    When I view the news and communications finder
    Then I see Updated (newest) order selected
    And I fill in some keywords
    And I press tab key to navigate
    Then I see Relevance order selected

  @javascript
  Scenario: Removing keyword filter in business finder
    When I view the business readiness finder
    Then I see Topic order selected
    And I fill in some keywords
    Then I see Relevance order selected
    And I click the Keyword1 remove control
    Then The keyword textbox only contains Keyword2
    And I see Relevance order selected
    And I click the Keyword2 remove control
    Then The keyword textbox is empty
    And I see Topic order selected

  @javascript
  Scenario: Adding keyword filter in business finder
    When I view the business readiness finder
    Then I see Topic order selected
    And I fill in some keywords
    And I press tab key to navigate
    Then I see Relevance order selected

  @javascript
  Scenario: Adding keyword filter to facet search in business finder
    When I view the business readiness finder
    Then I see Topic order selected
    And I select facet Aerospace in the already expanded "Sector / Business Area" section
    Then I see results grouped by primary facet value
    And I fill in some keywords
    And I press tab key to navigate
    Then I see Relevance order selected

  Scenario: Arrive at the business finder through Q&A
    Given the business finder QA exists
    When I visit the business finder Q&A
    And I select choice "Aerospace"
    And I submit my answer
    And I select choice "Sell goods or provide services in the UK"
    And I submit my answer
    And I skip the rest of the questions
    Then I should be on the business finder page
    And the correct facets have been pre-selected

  @javascript
  Scenario: Showing top result in business finder
    Given I am in the variant B control group
    When I view the business readiness finder
    And I fill in some keywords
    And I submit the form
    Then I see Relevance order selected
    And I see results with top result
    And The top result has the correct tracking data

  Scenario: Subscribing to email alerts
    Given a collection of documents exist that can be filtered by checkbox
    When I use a checkbox filter
    Then I can sign up to email alerts for allowed filters

  Scenario: Subscribing to email alerts with disallowed facets
    Given a collection of documents exist that can be filtered by checkbox
    When I use a checkbox filter and another disallowed filter
    Then I can sign up to email alerts for allowed filters

  @javascript
  Scenario: Subscribing to email alerts for business readiness finder
    When I view the business readiness finder
    And I create an email subscription
    Then I see the email subscription page
    And I can see the business finder filters

  @javascript
  Scenario: Filter documents by keywords and sort by most relevant
    When I view the news and communications finder
    And I fill in some keywords
    And I sort by most relevant
    Then I see Relevance order selected

  Scenario: Filter documents by keywords and sort by most relevant for business finder
    When I view the business readiness finder
    And I search documents by keyword for business finder
    And I sort by most relevant
    Then I see Relevance order selected

  Scenario: Group documents by facets
    When I view the business readiness finder
    Then I should see results in the default group

  @javascript
  Scenario: Filter documents and group by facets
    When I view the business readiness finder
    And I select facet Aerospace in the already expanded "Sector / Business Area" section
    Then I see results grouped by primary facet value

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
  Scenario: Facets should not be hidden by default on finders except all content
    When I view the research and statistics finder
    And I should not see a "Show more search options" button
    Then I view the all content finder
    And I should see a "Show more search options" button

  @javascript
  Scenario: A Blue Banner should be displayed when navigating from a topic page
    When I view the research and statistics finder with a topic param set
    Then I should see a blue banner

  @javascript
  Scenario: Facets should expand when clicking on the "Show more search options" button on all content
    When I view the all content finder
    And I should see a "Show more search options" button
    And I should not see a "Show fewer search options" button
    And Facets should be hidden
    Then I click "Show more search options" to expand all facets
    And I should see a "Show fewer search options" button
    And I should not see a "Show more search options" button
    And Facets should be visible

  Scenario: Results should be a landmark to allow screenreaders to jump to it quickly
    When I view the news and communications finder
    Then the page has a landmark to the search results
    And the page has a landmark to the search filters

  Scenario: "Show only Brexit results" checkbox is removed if the topic parameter is set to the Brexit Topic.
    When I view the news and communications finder filtered on the brexit topic
    Then I cannot see the "show only brexit results" checkbox

  Scenario: "Show only Brexit results" checkbox is shown if no topic parameter is set
    When I view the news and communications finder
    Then I can see the "show only brexit results" checkbox

  Scenario: Email links
    When I view the news and communications finder
    Then I see email and feed sign up links
    And I select a Person
    And I filter the results
    Then I see email and feed sign up links with filters applied

  @javascript
  Scenario: Email links
    When I view the news and communications finder
    Then I see email and feed sign up links
    And I click button "Person" and select facet Rufus Scrimgeour
    Then I see email and feed sign up links with filters and order applied

  @javascript
  Scenario: Policy papers should have three options
    When I view the policy papers and consultations finder
    And I select some document types
    Then I should see results for scoped by the selected document type

  Scenario: Choosing between document types with a research and statistics facet
    When I view the research and statistics finder
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

  @javascript
  Scenario: Finder has a clearable hidden input
    When I view the all content finder with a manual filter
    Then I can see results filtered by that manual
    And I click the Replacing bristles in your Nimbus 2000 remove control
    Then I see all content results

  Scenario: Atom Feed
    When I view the research and statistics finder
    And I click on the atom feed link
    Then I see the atom feed
