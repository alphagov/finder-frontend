# Finder Frontend

Renders search on GOV.UK:

- [Site search](https://www.gov.uk/search) is available from the header of every page.
- Finder pages provide facetted searching over a collection of documents.

## Live examples

* [gov.uk/aaib-reports](https://www.gov.uk/aaib-reports)
* [gov.uk/drug-device-alerts](https://www.gov.uk/drug-device-alerts)
* [gov.uk/government/case-studies](https://www.gov.uk/government/case-studies)
* [gov.uk/government/people](https://www.gov.uk/government/people)
* [gov.uk/world/organisations](https://www.gov.uk/world/organisations)
* [gov.uk/international-development-funding](https://www.gov.uk/international-development-funding)

Read more about [how links-based facets are handled](docs/finder-facets-links.md).

## Nomenclature

* Finder: Page containing a list of filterable documents and filters.
* Facets: Metadata associated with documents.
* Filters: Searchable/filterable metadata for example `case_state={open|closed}` for a CMA case.

## Running the application

```sh
$ ./startup.sh
```

You can optionally add the `--live` flag to use live search data.

If you are using the GDS development virtual machine then the application will be available on the host at [http://finder-frontend.dev.gov.uk/](http://finder-frontend.dev.gov.uk/)

## Running the test suite

Before you can run the test suite you'll need the [govuk-content-schemas] repository locally. See [`lib/govuk_content_schema_examples.rb`][content_schema_examples] for more details.

The StandardJS JavaScript linter needs to be installed separately before running the default `rake` task. To make sure that it's been installed run:

```sh
$ yarn install
```

The default `rake` task runs all the tests:

```sh
$ bundle exec rake
```

The application has Jasmine tests, which can be accessed at `/specs` when the application is running in development mode. These are also run when `rake`, above, is run.

To run the Jasmine tests separately: `bundle exec cucumber`

To run the JavaScript Jasmine tests separately: `bundle exec rake jasmine:ci`

Note: Running the JS tests require you to also install phantomjs with `brew cask install phantomjs`.

[govuk-content-schemas]: https://github.com/alphagov/govuk-content-schemas
[content_schema_examples]: https://github.com/alphagov/finder-frontend/blob/master/lib/govuk_content_schema_examples.rb

## Making a new finder

1. If required, add a schema to [alphagov/search-api](http://github.com/alphagov/search-api) describing your document type -- [example](https://github.com/alphagov/search-api/blob/master/config/schema/elasticsearch_types/cma_case.json)
2. Publish a Finder Content Item to the content store. See the doc for [Finder Content Item](https://github.com/alphagov/finder-frontend/blob/master/docs/finder-content-item.md) for more info.
3. Ensure your documents are indexed in [alphagov/search-api](http://github.com/alphagov/search-api) correctly.

### Developing a finder locally

You can run this application with a local file so you can develop a finder without having to publish the content item to the publishing-api.

For example:

```
DEVELOPMENT_FINDER_JSON=features/fixtures/aaib_reports_example.json ./startup.sh --live
```

### How to add a fixed filter

You can use [gov.uk/api/search.json?filter_link=](https://www.gov.uk/api/search.json?filter_link=) with the path of the page you looking for to migrate.

For example, you want to filter by the field `link` on `/government/world/organisations`
You can access the following: https://www.gov.uk/api/search.json?filter_link=/government/world/organisations/british-antarctic-territory
You will be able to see inside results the field `format`

You can double check the filter by performing the following search using search-api:

http://search-api.dev.gov.uk/search.json?filter_NAME=VALUE

For more information please refer to the [search api documentation](https://github.com/alphagov/search-api/blob/master/doc/search-api.md).

## Application structure

* No data store -- all data comes via the APIs mentioned above.
* `app/models` contains two kinds of object.
  1. Value objects used to wrap up responses from API calls.
  2. Facet objects which wrap up the behaviour of different types of facet --
     eg radios, selects, etc.
* `app/parsers` contains objects which transform API responses into models.
