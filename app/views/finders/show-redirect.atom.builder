policy_summary = <<~SUMMARY
  <p>
    We're changing the way content is organised on GOV.​UK. Policy pages and their atom feeds have been retired.
  </p>

  <p>
    The policy page for this feed has been replaced by a <a href="#{absolute_url_for(@redirect)}">topic page</a>.
  </p>

  <p>
    You might want to subscribe to any of the following feeds:
    <ul>
      <li><a href="#{absolute_url_for('/search/transparency-and-freedom-of-information-releases')}">Transparency and freedom of information releases</a></li>
      <li><a href="#{absolute_url_for('/search/research-and-statistics')}">Research and statistics</a></li>
      <li><a href="#{absolute_url_for('/search/policy-papers-and-consultations')}">Policy papers and consultations</a></li>
      <li><a href="#{absolute_url_for('/search/news-and-communications')}">News and communications</a></li>
    </ul>
  </p>
SUMMARY

generic_summary = <<~SUMMARY
  <p>
    This feed no longer exists.
  </p>

  <p>
    You might want to subscribe to any of the following feeds:
    <ul>
      <li><a href="#{absolute_url_for('/search/transparency-and-freedom-of-information-releases')}">Transparency and freedom of information releases</a></li>
      <li><a href="#{absolute_url_for('/search/research-and-statistics')}">Research and statistics</a></li>
      <li><a href="#{absolute_url_for('/search/policy-papers-and-consultations')}">Policy papers and consultations</a></li>
      <li><a href="#{absolute_url_for('/search/news-and-communications')}">News and communications</a></li>
    </ul>
  </p>
SUMMARY

atom_feed do |feed|
  feed.title("/#{@finder_slug}")

  feed.entry(
    nil,
    id: EntryPresenter.feed_ended_id(feed, @finder_slug),
    url: @redirect && absolute_url_for(@redirect),
  ) do |entry|
    entry.title("This feed has ended")

    summary = if @finder_slug.starts_with? "government/policies/"
                policy_summary
              else
                generic_summary
              end

    entry.summary(summary, type: "html")
  end
end
