atom_feed do |feed|
  feed.title(@feed.title)

  feed.updated(@feed.updated_at) if @feed.entries.present?

  feed.author do |author|
    author.name "HM Government"
  end

  @feed.entries.each do |result|
    feed.entry(result, id: result.tag(feed), url: absolute_url_for(result.path), updated: result.updated_at) do |entry|
      entry.title(result.title)
      entry.summary(result.summary, type: "html")
    end
  end
end
