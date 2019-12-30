# Finder email alerts

Users can subscribe to email alerts on finders. This document explains how
that works, and how to add or update email alerts on a finder.

![Transparency email alerts](/docs/assets/transparency-email-alerts.png)

## How does it work?

When a user clicks 'Get email alerts', they will be taken to a URL handled by
`email_alert_subscriptions_controller`. At this stage we decide which
[Email Alert API](https://github.com/alphagov/email-alert-api) subscriber list
the user will be subscribed to.

Sometimes a user will be shown an empty page with only a 'Create subscription'
button. In this case, the subscriber list will be determined from the filters
that a user used on the finder.

If a user had filtered their search on the Transparency and freedom of
information releases finder, this would affect the alerts that they would receive.

For example if the user filters by Topic: Defence and armed forces, and
Document Type: FOI release, and Organisation: Ministry of Defence, then the
'Get email alerts' link on the finder would look like this:

```
/search/transparency-and-freedom-of-information-releases/email-signup?
level_one_taxon=e491505c-77ae-45b2-84be-8c94b94f6a2b
&content_store_document_type%5B%5D=foi_release
&organisations%5B%5D=ministry-of-defence
&order=updated-newest
```

If you clicked that link you would be taken to this page:

![Transparency email signup](/docs/assets/transparency-alerts.png)

This page has a content item with a format of `finder_email_signup`. You can
[view this content item here](https://www.gov.uk/api/content/search/transparency-and-freedom-of-information-releases/email-signup).

Within the `details` of this content item, there is a `filter`, which contains
filters that will always be used for subscriptions. In this case a user will
always be subscribed to alerts on documents that have a `content_purpose_supergroup`
of `transparency`.

There is also an `email_filter_facets` array, that specifies the filters that
can be used on the subscriber list. For example, a user can filter their
subscription so that they only subscribe to documents with particular
`world_locations`, `organisations`, or `people`.

When you click 'Create subscription', behind the scenes a subscriber list
is found that matches those query parameters. If no matching subscriber list
is found then one is created.

In this case a subscriber list with the `topic_id` of `transparency-and-freedom-of-information-with-1-document-type-organisation-of-ministry-of-defence-and-topic-of-defence-and-armed-forces`

From this point, the subscriber list has been created and the user journey is
handled by [Email Alert Frontend](http://github.com/alphagov/email-alert-frontend).

Email alerting is handled by Email Alert API and Email Alert Service. You can [read more about how email notifications works here](https://docs.publishing.service.gov.uk/manual/email-notifications-how-they-work.html).

It is also possible for choices to be provided to the end user on the 'create
subscription' page:

![](/docs/assets/cma-alerts.png)

In this case, the user can modify the filters that they applied on the finder,
to change what they will be subscribed to.

## How do I add or update a finder email alert signup?

The `finder_email_signup` content items are published by [Search API](https://github.com/alphagov/search-api/blob/master/doc/publishing-finders.md).

To change the content of the page, you can update the content item in that
application, and then republish it.

To change the filters that a user can subscribe to, you also need to change the
content item.

For example, if you wanted to permit users to subscribe to documents published in
a particular city, you might add the following to `email_filter_facets`:

```json
{
  "facet_id": "city",
  "facet_name": "city"
},
```

## How do I use selected search filters as email filter facets?

If you would like to skip the email filter checkboxes and use the selected
search filters as email filters, set the value of `email_filter` to `all_selected_facets`.

**Note**: This is solution is in place until user email signup journeys are made consistent
across all finders.

You might also need to permit users to subscribe to this kind of tag.
In this case, you would need to add `city` to [the list of allowed `tags`
in Email Alert API](https://github.com/alphagov/email-alert-api/blob/3e0018510ea85f5d561e2865ad149832b94688a1/lib/valid_tags.rb#L2).

It's important to test that an email alert signup works, otherwise users won't
receive emails. You can validate this by manually testing against the
Email Alert Api or by adding a new end-to-end test for your subscriber list to
[publishing-e2e-tests](https://github.com/alphagov/publishing-e2e-tests/).
