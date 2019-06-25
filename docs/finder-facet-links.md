# Links-based facets

The [EU Exit Business Readiness Finder](https://www.gov.uk/find-eu-exit-guidance-business) ("business finder") uses 'links' to filter the finder and retrieve content from different publishing apps.

In most finders:

- search results get more granular as you select values in different facets (the number of results goes down)
- search results only show content from one publishing app

In links-based facet finders:

- search results get more _broad_ as you select values in different facets (the number of results goes up)
- search results can show content from multiple publishing apps.

These results can be sorted by topic ("grouped display"). In this context, a 'topic' is the label of the facet (such as 'Personal data'), except for the 'Sector / Business area' facet, where the _facet value_ (such as 'Aerospace') is the topic.

![Screenshot of 'Sort by Topic'](https://user-images.githubusercontent.com/93511/52811122-38eb2500-308c-11e9-843f-4df29b719235.png)

## Implementation

Standard finders use facets that have been published as part of the content item itself, which therefore appear under `details["facets"]` in the [content item JSON](https://www.gov.uk/api/content/cma-cases).

The business finder uses facets that reference 'links' (published by content-tagger), which therefore appear under `links["facet_group"]` in the [business finder content item JSON](https://www.gov.uk/api/content/find-eu-exit-guidance-business).

These are called "details-based facets" and "links-based facets" respectively:

| details-based facets | links-based-facets |
|----------------------|--------------------|
|![screenshot of content item JSON for /cma-cases](https://user-images.githubusercontent.com/5111927/60020202-6f166200-9687-11e9-86e9-1ba9020f0e27.png)|![screenshot of content item JSON for /find-eu-exit-guidance-business](https://user-images.githubusercontent.com/5111927/60020210-73db1600-9687-11e9-9cb8-e942964a27dc.png)|

Selected facets are compiled into a list of `filter_facet_values[]` request params (containing UUID search parameters) and sent to the [search-api](https://github.com/alphagov/search-api). The search API combines this list of UUIds into an `OR` query.
