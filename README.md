# Finder Frontend

Renders search on GOV.UK:

- [Site search](https://www.gov.uk/search) is available from the header of every page.
- Finder pages provide facetted searching over a collection of documents.
- Most of these pages support [subscribing to email alerts](docs/finder-email-alerts.md).

## Live examples

* [gov.uk/aaib-reports](https://www.gov.uk/aaib-reports)
* [gov.uk/drug-device-alerts](https://www.gov.uk/drug-device-alerts)
* [gov.uk/government/case-studies](https://www.gov.uk/government/case-studies)
* [gov.uk/government/people](https://www.gov.uk/government/people)
* [gov.uk/world/organisations](https://www.gov.uk/world/organisations)
* [gov.uk/international-development-funding](https://www.gov.uk/international-development-funding)

## Nomenclature

* Finder: Page containing a list of filterable documents and filters.
* Facets: Metadata associated with documents. See `app/models/*_facet.rb` for examples.
* Filters: Searchable/filterable metadata for example `case_state={open|closed}` for a CMA case.
* Parser: Transforms API responses into model objects.

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

### Running the app locally

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) or the local `startup.sh` script to run the app. Read the [guidance on local frontend development](https://docs.publishing.service.gov.uk/manual/local-frontend-development.html) to find out more about each approach, before you get started.

- `govuk-docker-up` builds finder-frontend and all its dependent applications
- `govuk-docker-up app-live` builds finder-frontend pointing at the production content store and search stack
- `govuk-docker-up app-integration` builds finder-frontend pointing at the integration content store and search stack
- `govuk-docker-up app-live-local-search` builds finder-frontend pointing at the live content store and a local version of search api.

### Running the test suite

If you are using GOV.UK Docker, remember to prefix the commands that follow with `govuk-docker-run`. See the [GOV.UK Docker usage instructions](https://github.com/alphagov/govuk-docker#usage) for examples.

```sh
# run all the tests
bundle exec rake

# run only feature tests
bundle exec cucumber

# run only JS tests
bundle exec rake jasmine:ci
```

### Further documentation

See the [`docs/`](docs/) directory for manuals and instructions.

## Licence

[MIT License](LICENCE)
