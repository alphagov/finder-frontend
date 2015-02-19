atom_feed do |feed|
  feed.title(@feed.title)

  feed.updated(@feed.updated_at) if @feed.entries.length > 0

  feed.author do |author|
    author.name 'HM Government'
  end

  @feed.entries.each do |result|
    feed.entry(result, id: result.path, url: absolute_url_for(result.path), updated: DateTime.parse(result.last_update)) do |entry|
      entry.title(result.title)
      entry.summary(result.summary, type: 'html')
    end
  end
end
