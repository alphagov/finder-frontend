#Finder Frontend

##Purpose
![Finder frontend screenshot](https://raw.githubusercontent.com/alphagov/finder-frontend/master/docs/assets/page-screenshot.png)

Faceted searching over documents.

##Nomenclature
* Finder: Page containing a list of filterable documents and filters.
* Facets: Metadata associated with documents.
* Filters: Searchable/filterable metadata for example `case_state={open|closed}` for a CMA case.

##Current finders
* [gov.uk/aaib-reports](https://www.gov.uk/aaib-reports)
* [gov.uk/cma-cases](https://www.gov.uk/cma-cases)
* [gov.uk/drug-safety-update](https://www.gov.uk/drug-safety-update)
* [gov.uk/drug-device-alerts](https://www.gov.uk/drug-device-alerts)
* [gov.uk/government/case-studies](https://www.gov.uk/government/case-studies)
* [gov.uk/government/groups](https://www.gov.uk/government/groups)
* [gov.uk/government/people](https://www.gov.uk/government/people)
* [gov.uk/government/world/organisations](https://www.gov.uk/government/world/organisations)
* [gov.uk/international-development-funding](https://www.gov.uk/international-development-funding)
* [gov.uk/maib-reports](https://www.gov.uk/maib-reports)
* [gov.uk/raib-reports](https://www.gov.uk/raib-reports)

##Dependencies
* [alphagov/static](http://github.com/alphagov/static): provides static assets (JS/CSS) and provides the GOV.UK templates.
* [alphagov/content-store](http://github.com/alphagov/content-store): provides the content items for the finder itself -- containing the finder title, tagged organisations and related links
* [alphagov/rummager](http://github.com/alphagov/rummager): provides search results

##Running the application

```
$ ./startup.sh
```

If you are using the GDS development virtual machine then the application will be available on the host at [http://finder-frontend.dev.gov.uk/](http://finder-frontend.dev.gov.uk/)

##Running the test suite

Before you can run the test suite you'll need the [govuk-content-schemas]
repository locally. See
[`lib/govuk_content_schema_examples.rb`][content_schema_examples] for more
details.

The default `rake` task runs all the tests:

```
$ bundle exec rake
```

The application has jasmine tests, which can be accessed at `/specs` when the application is running in development mode. These are also run when `rake`, above, is run.

[govuk-content-schemas]: https://github.com/alphagov/govuk-content-schemas
[content_schema_examples]: https://github.com/alphagov/finder-frontend/blob/master/lib/govuk_content_schema_examples.rb

##Making a new finder
1. If required, add a schema to [alphagov/rummager](http://github.com/alphagov/rummager) describing your document type -- eg
   [https://github.com/alphagov/rummager/blob/master/config/schema/default/doctypes/cma_case.json](https://github.com/alphagov/rummager/blob/master/config/schema/default/doctypes/cma_case.json)
2. Publish a Finder Content Item to the content store. See the doc for [Finder Content Item](https://github.com/alphagov/finder-frontend/blob/master/docs/finder-content-item.md) for more info.
3. Ensure your documents are indexed in [alphagov/rummager](http://github.com/alphagov/rummager) correctly.

##Application structure
* No data store -- all data comes via the APIs mentioned above.
* `app/models` contains two kinds of object.
  1. Value objects used to wrap up responses from API calls.
  2. Facet objects which wrap up the behaviour of different types of facet --
     eg radios, selects, etc.
* `app/presenters` contains objects which serialise the value objects to hashes
  for display via mustache.
* `app/parsers` contains objects which transform API responses into models.
