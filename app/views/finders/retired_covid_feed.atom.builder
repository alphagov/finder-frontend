summary = <<~SUMMARY
  <p>
    We've changed the way coronavirus content is organised on GOV.​UK to help you find information more easily.
  </p>

  <p>
    You might want to subscribe to any of the following feeds:
    <ul>
      <li><a href="#{absolute_url_for('/search/all?level_one_taxon=5b7b9532-a775-4bd2-a3aa-6ce380184b6c')}">All coronavirus content</a></li>
      <li><a href="#{absolute_url_for('/search/all?level_one_taxon=5b7b9532-a775-4bd2-a3aa-6ce380184b6c&content_purpose_supergroup%5B%5D=news_and_communications&order=updated-newest')}">News and communications</a></li>
      <li><a href="#{absolute_url_for('/search/all?level_one_taxon=5b7b9532-a775-4bd2-a3aa-6ce380184b6c&content_purpose_supergroup%5B%5D=policy_and_engagement&order=updated-newest')}">Policy papers and consultations</a></li>
      <li><a href="#{absolute_url_for('/search/all?level_one_taxon=5b7b9532-a775-4bd2-a3aa-6ce380184b6c&content_purpose_supergroup%5B%5D=research_and_statistics&order=updated-newest')}">Research and statistics</a></li>
    </ul>
  </p>
SUMMARY

atom_feed do |feed|
  feed.title("/#{@finder_slug}")
  feed.updated(Time.zone.iso8601("2020-06-24T00:00:00"))

  feed.entry(
    nil,
    id: EntryPresenter.feed_ended_id(feed, @finder_slug),
    url: absolute_url_for("/search/all?level_one_taxon=5b7b9532-a775-4bd2-a3aa-6ce380184b6c"),
  ) do |entry|
    entry.title("This feed has ended")
    entry.summary(summary, type: "html")
    entry.updated(Time.zone.iso8601("2020-06-24T00:00:00").rfc3339)
    entry.author do |author|
      author.name("HM Government")
    end
  end
end
