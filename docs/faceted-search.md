Faceted search
==================

This document explains how you would add a facet to a finder.

## Terminology

A **finder** is a search page served by GOV.UK. These pages are the main interface that people use to search for government services and information.

Finder pages are served by finder-frontend, this repository. If this is news to you, first read [how search works][].

Finders provide [faceted search][]. The components on the side of search results below are facets (e.g. topic, organisation).

[![Faceted search screenshot](/docs/assets/sitesearch-screenshot.png)](https://www.gov.uk/search)

A **filter** is a query parameter passed to Search API that will return all documents that match. For example organisations=hmrc,fco,mod. See the [Search API documentation][] for more details about filtering.

A **facet** is a user-interface (UI) component that people can use to apply filters to their search results.

## Adding facets to finders

For a user to apply a given filter to a search page, we must first add a corresponding facet to the page.

The [RAIB reports][] finder has a corresponding [raib reports content item][].

This finder has three facets: Railway type, Report type, and Date.

When a user selects e.g. "Heavy rail" from the "Railway type" option select box, finder-frontend attaches the filter `railway_type=heavy-rail` to the search query sent to Search API.

For more details about the facet schema, see the finder [facets schema descriptions][]. Warning: some of the fields defined in the schema are no longer used (`combine_mode`), and others are present but should not be used (`option_lookup`).

```json
[
  {
    "key": "railway_type",
    "name": "Railway type",
    "type": "text",
    "preposition": "of type",
    "display_as_result_metadata": true,
    "filterable": true,
    "allowed_values": [
      {
        "label": "Heavy rail",
        "value": "heavy-rail"
      },
      {
        "label": "Light rail",
        "value": "light-rail"
      },
      ...
    ]
  },
  ...
]
```

Here the values for the facet are static, they are hard-coded into the content item JSON under `allowed_values`. When we want to change the values that a user may filter by, we'd need to edit the JSON (in specialist publisher in this case) and republish the finder to the publishing-api.

To add a facet add an object to the facets list in the finder content item JSON with the required keys from the schema.

Finders are published by Specialist Publisher and Search API. You'll find some prior art for facets in Search API's [config/finders][] directory.

Facets can be of various `type`s which affect the way they are displayed to users.

You can find the [available types in the schema][].

## Facets with 'dynamic' data

For some facets here may be many allowed values and the permitted values can change frequently.

The people facet enables users to filter by the person that documents are tagged to.

However, there are a great many people, and they are often added, removed, and modified. Hard-coding the list of people into the `allowed_values` of a facet in a content item would make the JSON we fetch from the content store much larger. It would also be hard to maintain, since developers would need to amend the finder manually whenever a person is created/changed/removed.

In these cases we use **dynamic facets**.

Below is a dynamic facet for filtering by organisation. The `allowed_values` are provided by finder-frontend at runtime.

```json
{
  "display_as_result_metadata": true,
  "filterable": true,
  "key": "organisations",
  "name": "Organisation",
  "preposition": "from",
  "short_name": "From",
  "type": "text",
  "show_option_select_filter": true
}
```

Dynamic facets are pretty similar to other facets. The only difference is that their `allowed_values` are populated by finder-frontend, rather than in the content item.

To provide the values for a dynamic facet, finder-frontend operates a read-ahead cache of [registries][].

If you are adding a dynamic facet for a new filter type (e.g. roles), you'll need to add or modify a registry in finder-frontend, in order to make the values for your facet available to the UI component.

This may involve modifying Search API to provide the aggregations for a field, which populate the registries. For example the [aggregations for people][].

In future we could use aggregations to fetch the available values for each facets from Search API directly. Finder-frontend at one point did this. However, doing these aggregations at query time would come with a performance cost. Another option might be to autogenerate the `allowed_values` for a facet by listening to the publishing queue.

## Hidden facets

Sometimes it can be useful to permit filtering on a finder without displaying a facet UI component to users. In these cases we use **hidden facets**.

Examples of these include [manual searches][] and [topic searches][].

Notice how those two links apply a filter to search using a query parameter? That is because those finder pages have a hidden facet.

The services finder has this facet:

```json
{
  "key": "topic",
  "filter_key": "all_part_of_taxonomy_tree",
  "name": "topic",
  "short_name": "topic",
  "type": "hidden",
  "display_as_result_metadata": false,
  "hide_facet_tag": true,
  "filterable": true
}
```

The type `hidden` means that users won't see the facet in the UI. Setting `filterable: true` means the user can use `topic` in a query parameter.

The search homepage has a facet that enables filtering by manuals. Here the type is `hidden_clearable`, which seems to function in the exact same way as `hidden`.

```json
{
  "display_as_result_metadata": false,
  "filterable": true,
  "key": "manual",
  "name": "Manual",
  "preposition": "in manual",
  "short_name": "in",
  "type": "hidden_clearable",
  "show_option_select_filter": false,
  "allowed_values": []
}
```

[how search works]: https://github.com/alphagov/finder-frontend/blob/6faf8f865ce1b0a82c296e6eb8e1d5bc2da1bd72/docs/how-search-works.md
[Search API documentation]: https://github.com/alphagov/search-api/blob/0236e8e697f661524f11090a3d0f3b56f4786eb5/doc/search-api.md#using-the-search-api
[faceted search]: https://en.wikipedia.org/wiki/Faceted_search
[RAIB reports]: https://www.gov.uk/raib-reports
[raib reports content item]: https://www.gov.uk/api/content/raib-reports
[facets schema descriptions]: https://github.com/alphagov/govuk-content-schemas/blob/0812e083f33ae98daa3f98d5106c0eae807468bc/dist/formats/finder/frontend/schema.json#L396
[manual searches]: https://www.gov.uk/search/all?manual%5B%5D=%2Fhmrc-internal-manuals%2Fadmin-law-manual&q=advice
[topic searches]: https://www.gov.uk/search/services?topic=d6c2de5d-ef90-45d1-82d4-5f2438369eea
[registries]: https://github.com/alphagov/finder-frontend/blob/6faf8f865ce1b0a82c296e6eb8e1d5bc2da1bd72/docs/registries.md
[config/finders]: https://github.com/alphagov/search-api/tree/0236e8e697f661524f11090a3d0f3b56f4786eb5/config/finders
[available types in the schema]: https://github.com/alphagov/govuk-content-schemas/blob/0812e083f33ae98daa3f98d5106c0eae807468bc/dist/formats/finder/frontend/schema.json#L495-L505
[aggregations for people]: https://www.gov.uk/api/search.json?aggregate_people=10&count=0
