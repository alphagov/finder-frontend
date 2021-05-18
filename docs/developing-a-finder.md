# Developing a Finder

1. If required, add a schema to [alphagov/search-api](http://github.com/alphagov/search-api) describing your document type -- [example](https://github.com/alphagov/search-api/blob/master/config/schema/elasticsearch_types/cma_case.json)

2. Publish a Finder Content Item to the content store. See the doc for [Finder Content Item](https://github.com/alphagov/finder-frontend/blob/master/docs/finder-content-item.md) for more info.

3. Ensure your documents are indexed in [alphagov/search-api](http://github.com/alphagov/search-api) correctly.
