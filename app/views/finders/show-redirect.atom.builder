policy_summary = <<~SUMMARY
  <p>
    We're changing the way content is organised on GOV.​UK. Policy pages, and the corresponding atom feeds have been retired.
  </p>

  <p>
    You might want to subscribe to <a href="#{absolute_url_for('/government/publications')}">publications</a> or <a href="#{absolute_url_for('/government/announcements')}">announcements</a>.
  </p>
SUMMARY

generic_summary = <<~SUMMARY
  <p>
    This feed no longer exists.
  </p>

  <p>
    You might want to subscribe to <a href="#{absolute_url_for('/government/publications')}">publications</a> or <a href="#{absolute_url_for('/government/announcements')}">announcements</a>.
  </p>
SUMMARY

atom_feed do |feed|
  feed.title('Feed Ended')

  feed.entry(
    nil,
    id: EntryPresenter.feed_ended_id(feed, @finder_slug),
    url: @redirect && absolute_url_for(@redirect),
  ) do |entry|
    entry.title("/#{@finder_slug} feed ended")

    summary = if @finder_slug.starts_with? 'government/policies/'
                policy_summary
              else
                generic_summary
              end

    entry.summary(summary, type: 'html')
  end
end
