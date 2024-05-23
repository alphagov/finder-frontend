# Search APIs
Finder Frontend can use either "v1" [`search-api`][search-api] or [`search-api-v2`][search-api-v2]
depending on the finder in use and the parameters of a user's search.

Note that v2 is not (yet) able to handle all the use cases of v1, and the extent to which v1 use
cases will be migrated is still under discussion.

## Forcing the use of a specific API
The `use_v1` and `use_v2` query parameters are available on the `finders#show` action and take
precedence over any other logic. These are useful for comparing results and debugging.

## Using v1 as a backup in case of v2 issues
In the event of a major issue with `search-api-v2` or its underlying SaaS search product (Google
Vertex AI Search), a feature flag `FORCE_USE_V1_SEARCH_API` is available and will force all search
traffic to use the v1 API.

The v1 API provides pure keyword search and lacks the "smart" semantic search of v2, leading to
significantly poorer result quality for more complex searches. Consider whether the issue with v2 is
uncontained, escalating, or has significant user impact before enabling the fallback.

[search-api]: https://github.com/alphagov/search-api
[search-api-v2]: https://github.com/alphagov/search-api-v2
