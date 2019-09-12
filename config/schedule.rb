# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, error: "log/cron.error.log", standard: "log/cron.log"

bundler_prefix = ENV.fetch("BUNDLER_PREFIX", "/usr/local/bin/govuk_setenv finder-frontend")
job_type :rake, "cd :path && #{bundler_prefix} bundle exec rake :task :output"

cache_refresh_schedule = Random.new.rand(45..60)
every cache_refresh_schedule.minutes do
  rake "registries:cache_refresh"
end

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
