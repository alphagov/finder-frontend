namespace :content_store do
  desc "
  Fetch content items from content store and add to cache
  Fetching content store data takes a while. Rather than have a user
  experience a delay while we read-through an empty cache, we write ahead to
  the cache with this job at regular intervals.
  "
  task refresh_cache_hard: :environment do
    puts "Refreshing content store cache..."
    Services::ContentStore.new.hard_refresh_cache
    puts "Finished refreshing content store cache."
  end

  desc "
  Fetch data for content items and add to cache _if they are not already present_.
  This job will be used as part of the deploy.  It should only affect servers with
  empty caches (which are probably new).
  Caches are refreshed on a schedule with content_store:cache_refresh.
  "
  task refresh_cache_soft: :environment do
    puts "Ensuring content items are cached..."
    Services::ContentStore.new.soft_refresh_cache
    puts "Finished ensuring content items are cached."
  end
end
