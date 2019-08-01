# Analytics

To improve the search user experience, we track user behaviour in Google
Analytics.

## What is tracked

In addition to the default page view tracking that occurs on every page
of GOV.UK, we have added additional tracking to finder-frontend.

There are three kinds of tracking:

- Enhanced Ecommerce: Provided by [static](https://github.com/alphagov/static/blob/master/app/assets/javascripts/analytics/ecommerce.js); provides analytics on views (impressions) and clicks of lists of items.
- Event tracking: tracks usage of features such as facets.
- Page view tracking: tracks each search that a user makes.

## Testing analytics

For Enhanced Ecommerce, the tracking functionality is tested in static.

We have feature tests to check the correct attributes are used in
[`features/analytics.feature`](features/analytics.feature).

There are also unit tests, e.g. in [`spec/javascripts/live_search_spec.js`](spec/javascripts/live_search_spec.js).
