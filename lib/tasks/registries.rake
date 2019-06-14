namespace :registries do
  desc "
  Fetch data for registries and add to cache
  Fetching registry data takes a while. Rather than have a user
  experience a delay while we read-through an empty cache, we write ahead to
  the cache with this job at regular intervals (and as part of the deploy).
  "
  task cache_refresh: :environment do
    puts "Refreshing registry cache..."
    # TODO: refresh caches.
    puts "Finished refreshing registry cache."
  end
end
