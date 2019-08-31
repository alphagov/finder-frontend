namespace :registries do
  desc "
  Fetch data for registries and add to cache
  Fetching registry data takes a while. Rather than have a user
  experience a delay while we read-through an empty cache, we write ahead to
  the cache with this job at regular intervals.
  "
  task cache_refresh: :environment do
    puts "Refreshing registry cache..."
    Registries::BaseRegistries.new.refresh_cache
    puts "Finished refreshing registry cache."
  end

  desc "
  Fetch data for registries and add to cache _if they are not already present_.
  This job will be used as part of the deploy.  It should only affect servers with
  empty caches (which are probably new).
  Caches are properly refreshed on a schedule.
  "
  task cache_warm: :environment do
    puts "Making sure registry cache is warm..."
    Registries::BaseRegistries.new.ensure_warm_cache
    puts "Finished making registry cache toasty."
  end
end
