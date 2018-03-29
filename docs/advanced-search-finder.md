# Advanced search finder

The **advanced search** finder deviates slightly from the classic abstract finder-frontend patterns to accommodate filtering by `taxons`, `content_purpose_supergroups` and `content_purpose_subgroups`.

The need for this arises from larger volumes of content being tagged to the taxonomy and filtering content-rich taxons by content types provides an effective mechanism to searching across a topic.


## Request parameters

* `topic` (Required) - Alias for rummager search parameter `taxons`. Filters results to content tagged to the specified taxon path. eg. `topic=/education`.
* `group` (Required) - Alias for rummager search parameter `content_purpose_supergroup`. Instead of pre-defined facets, the publication type filters are populated from the [govuk_document_types](https://github.com/alphagov/govuk_document_types) gem based on the `group` parameter.
* `subgroup` (Optional) - Alias for rummager search parameter `content_purpose_subgroup`. This optional parameter narrows the content filter to specific types of content. The parameter obeys the Rails convention of array parameters. eg. `subgroup[]=news&subgroup[]=updates_and_alerts`.

Without the required parameters, this responds with 404.


## Implementation details

The advanced search finder is available at the path `/search/advanced`. The underlying content item is published via a [rake task in Rummager](https://github.com/alphagov/rummager/blob/master/lib/tasks/advanced_search.rake).

The advanced search finder uses much of the facet filtering abilities of the finder-frontend, the `subgroup` facet values are loaded dynamically depending on the parent `group` (`content_purpose_supergroup`) parameter. The group and subgroup definitions are stored in [govuk_document_types](https://github.com/alphagov/govuk_document_types).

The advanced search finder has a distinct [controller](https://github.com/alphagov/finder-frontend/blob/master/app/controllers/advanced_search_finder_controller.rb), [api service class](https://github.com/alphagov/finder-frontend/blob/master/app/lib/advanced_search_finder_api.rb) and [query builder](https://github.com/alphagov/finder-frontend/blob/master/app/lib/advanced_search_query_builder.rb) to provide the necessary functionality without affecting or compromising the original finder codebase.


## Example advanced search finder URLs

* [gov.uk/search/advanced?group=news_and_communications&topic=%2Feducation](https://www.gov.uk/search/advanced?group=news_and_communications&topic=%2Feducation)
* [gov.uk/search/advanced?group=guidance_and_regulation&topic=%2Fmoney](https://www.gov.uk/search/advanced?group=guidance_and_regulation&topic=%2Fmoney)
* [gov.uk/search/advanced?keywords=&subgroup%5B%5D=guidance&subgroup%5B%5D=regulation&public_timestamp%5Bfrom%5D=&public_timestamp%5Bto%5D=&topic=%2Fmoney&group=guidance_and_regulation](https://www.gov.uk/search/advanced?keywords=&subgroup%5B%5D=guidance&subgroup%5B%5D=regulation&public_timestamp%5Bfrom%5D=&public_timestamp%5Bto%5D=&topic=%2Fmoney&group=guidance_and_regulation)
