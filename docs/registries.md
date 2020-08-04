# Registries

The registries module (app/lib/registries) provides datasets from other
applications.

These registries are intended to be used when rendering facets.
For example, the OrganisationsRegistry provides the data for the organisations
facet.

Each registry fetches data from another application (such as search-api
or whitehall), and caches it locally.

## Motivation for registries

Frontend applications like finder-frontend, according to GOV.UK architecture
guidelines, should not have a data store.

We have slightly broken this rule to decrease page load times. If we don't
make additional requests for facets, and if our queries request less data,
then we can return search results to users faster.

## Caching

We cache the data for each registry in memcached, using the dalli gem.

There is a separate instance of memcached running on each machine, so the
stores can be out of sync.

We refresh the cache using the `registries:cache_refresh` rake task.

The cached data is refreshed routinely using a cron job, defined in
`config/schedule.rb` and administrated with the [whenever](https://github.com/javan/whenever)
gem.

The cache is refreshed during a deploy, too.

Both the deploy time and routine cache refreshes are called in the
`govuk-app-deployment` deploy. The capistrano deploy process supplies data to
the cache and sets up the cron job.

## Alerts

We have a healthcheck for the registry caches, so we know when
there are empty registries. Poor health will be reported in Icinga.
They are defined in `app/lib/healthchecks`.
