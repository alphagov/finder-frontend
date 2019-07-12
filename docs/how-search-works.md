# How search works

This document explains at a high level what happens when you submit a search query at https://www.gov.uk/search (site search).

[![Site search screenshot](/docs/assets/sitesearch-screenshot.png)](https://www.gov.uk/search)

## The role of finder-frontend.

Finder-frontend provides the frontend for search. The application accepts
search queries from users, makes requests to [Search API](https://github.com/alphagov/search-api)
using those queries, and then renders the results of those queries as HTML.

This guide doesn't go into how Search API handles requests. For more detail
on this please see the [Search API docs](https://docs.publishing.service.gov.uk/apis/search/search-api.html).

## What happens when I submit a search query?

To render a search page finder-frontend takes a users query parameters such as
`q=breakfast` and the request path `/breakfast-finder`, and then makes a
query to two APIs: [Content Store](https://github.com/alphagov/content-store)
and [Search API](https://github.com/alphagov/search-api).

This is the high level sequence of actions finder-frontend takes when you submit a query:

1. Fetches the content item for the finder
2. With the content item and a user's query parameters, a Search API query is built
3. The query is sent to Search API, which responds with search results
4. The search results and details from the content item are rendered as HTML

### Fetching the content item

Pretty much the first thing finder-frontend does when you make a request is
get hold of the content item for the finder.

```ruby
ContentItem.from_content_store('/search/services') # gets content item (from memcached / API)
```

We call the Content Store to get the content item. Like the majority of pages on GOV.UK, all search pages have an associated [content item](docs/finder-content-item.md).

For example, site search's content item is here: https://www.gov.uk/api/content/search.

The content item plays an important role. The content item determines:

- how we should translate a user's request into a query to Search API
- how we should render the page (facets available, markup)

#### Example

The [services](https://www.gov.uk/search/services) finder is a search page and
[here is its content item](https://www.gov.uk/api/content/search/services).

The content item helps us to render the page.
It has fields such as `title` ("Services") and `description` ("Find services
from government"), which we render on the page.

The content item also affects how we query the Search API.

For example, it provides the field `default_documents_per_page: 20`. This tells us to
display 20 results per page by default. We'll only fetch the top 20 results
from Search API in this case.

The `filter` field tells us to apply some filters by default to our Search API
query. In this case `"content_purpose_supergroup": ["services"]` will be added
to every search query, but, like `default_documents_per_page`, this will be hidden
from the user.

There are other more involved bits of information provided by the content item,
such as facets, which affect both how we render pages and how we query Search API.

Search content items are published by Search API and Specialist Publisher.

### Querying the Search API

The query we make to Search API is performed by [`Search::Query`](app/lib/search/query.rb).

Using the content item and a user's query parameters, `Search::Query` makes a
query to Search API.

The single request made to Search API asks for a lot of different data.

As part of a single query we specify pagination, return fields, user keyword input,
any filters that the content item includes, the order of results, applied filters,
aggregates of our applied filters, and debug params.

See the query builder classes in the `Search` module for details on the query that gets sent to Search API. For instance, `Search::OrderQueryBuilder` specifies the `order` param, e.g. `order=-popularity`.

See the [Search API field reference](https://docs.publishing.service.gov.uk/apis/search/fields.html) for all available fields!

### Presenting the results

With the response from the Search API, we're ready to start rendering the page.

`FindersController` calls various presenter classes such as `PaginationPresenter`
with the data from the content item and search response and then provides the
presented data to the views.

There's a fair bit of munging of data, and special things going on as you might expect. But this is the bones of it.

## Progressive enhancement

This application does not require users to enable Javascript.

For users with Javascript enabled, the application is progressively enhanced to
render subsequent results without a page reload.

If you land on `/search/all` and search for something (with JS enabled), your results will be updated *live*. This is great, as we can return results to users quicker. We follow the common GOV.UK pattern: When a search query is performed we make a call to a JSON endpoint which returns pre-rendered HTML, and with fancy JS we replace the elements in the DOM with the updated elements we've received.
