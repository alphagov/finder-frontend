# The Finder Content Item Format

A Finder Content Item is a specialisation of the [Content Item](https://github.com/alphagov/content-store/blob/master/doc/content_item_fields.md). This guide explains what goes in the details hash of the ContentItem and why.

The Finder Content Item is used by Finder Frontend to render the Finder page. Most of what it uses goes in the `details` hash.

# The `details` hash

## `beta`

A boolean. Required.

A flag used to decide if the Beta banner should be rendered.

## `beta_message`

A string. Optional. Can be set to `null`.

Can contain HTML. If `beta` is true, `beta_message` will be passed to the beta banner.

## `document_noun`

A string. Required.

The lowercase singular version of whatever format the Finder is using. For example: [`/cma-cases`](https://www.gov.uk/cma-cases) has a `document_noun` of `case`, [`/aaib-report`](https://www.gov.uk/aaib-reports) has a `document_noun` of `report`. This is used to construct the sentence descriving the current search by the user.

## `document_type`

A string. Required.

[snake_case](http://en.wikipedia.org/wiki/Snake_case) string which tells Finder Frontend what doctype to limit the search to in Rummager. It must match the name of the file describing the doctype [in Rummager](https://github.com/alphagov/rummager/tree/master/config/schema/default/doctypes).

## `email_signup_enabled`

A boolean. Required.

Used to decide if the link to the email alert signup page should be displayed

## `format_name`

A string. Optional.

Not specifically used by the Finder, but used by [Specialist Frontend](https://github.com/alphagov/specialist-frontend) to link back to the Finder.
Usually a singularised version of the title of the Finder - `"Competition and Markets Authority case"` for [`/cma-cases`](https://www.gov.uk/cma-cases) for example.
However there are edge cases where it's not the same such as `"Medical safety alert"` for [Alerts and recalls for drugs and medical devices](https://www.gov.uk/drug-device-alerts).

## `signup_link`

A string. Optional.

If `email_signup_enabled` is set to true, the link being displayed will point to `base_path/email-signup` where `base_path` is from the Finder object. `signup_link` allows you to point it at a different URL, [Drug Safety Update](https://www.gov.uk/drug-safety-update) and [Drug Device Alerts](https://www.gov.uk/drug-device-alerts) are the two which currently use this feature.

## `show_summaries`

A boolean. Required.

Used to decide if the summaries for Documents should be displayed in the results list. It will truncate the summary at the end of the first sentence.

## `facets`

An array of hashes. Optional.

Facets describe the metadata that the Finder deals with. They can contain several keys:

### `key`

A string. Required.

`snake_case` string which matches to the field being searched in Rummager.

### `filterable`

A boolean. Required.

Specifies if the facet should have a matching Filter for the results.

### `display_as_result_metadata`

A boolean. Required.

Specifies if the facet should be returned as metadata underneath each result.

### `name`

A string. Required.

Used to label the filter panel for the facet.

For date facets, it may be used to label the metadata shown for each result. (See also short_name)

### `preposition`

A string. Required if `filterable` is set to `true`.

Is prepended to the name of the Filter when constructing the `sentence_fragment` for that Filter.

### `type`

A string set to `date` or `text`. Required.

If `filterable` is `true`, this generates a `date` or `multi-select` Filter respectively. If `display_as_result_metadata` is ` true` and this is set to `date`, it will present the date as `DD Month YYYY` under the result.

### `short_name`

A string. Optional.

For dates, the name of the Filter may be too long, such as `Date of occurrence`. The field lets you specify a short name. For the `Date of occurrence` example, the `short_name` would be `Occurred`.

### `allowed_values`

An array of hashes. Required if `filterable` is set to `true` and `type` is set to `text`.

The `allowed_values` array contains hashes with the following keys and values:

#### `label`

A string. Required.

Displayed as the label for the option in the `multi-select` Filter and as the label in the `sentence_fragment`.

#### `value`

A string. Required.

Appended to the URL when the option is select. Usually a paramterized slug of the label, but it doesn't need to be a direct 1:1.

# Outside of the details hash

## `links`

### `organisations`

Currently, only the first Organisation is displayed as metadata on the Finder.

### `email_alert_signup`

This is the Content Item for the email-signup for the Finder. Most of these live at `#{base_path}/email-signup` but there's no reason this couldn't point anywhere else.
