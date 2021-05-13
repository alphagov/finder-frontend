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
* Facets: Metadata associated with documents. See `app/models/*_facet.rb` for examples.
* Filters: Searchable/filterable metadata for example `case_state={open|closed}` for a CMA case.
* Parser: Transforms API responses into model objects.

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) or the local `startup.sh` script to run the app. Read the [guidance on local frontend development](https://docs.publishing.service.gov.uk/manual/local-frontend-development.html) to find out more about each approach, before you get started.

If you are using GOV.UK Docker, remember to combine it with the commands that follow. See the [GOV.UK Docker usage instructions](https://github.com/alphagov/govuk-docker#usage) for examples.

### Running the test suite

```sh
# run all the tests
bundle exec rake

# run only feature tests
bundle exec cucumber

# run only JS tests
bundle exec rake jasmine:ci
```

### Making a new finder

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
