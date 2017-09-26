if ENV['HEROKU_APP_NAME'].present?
  Rake::Task['assets:precompile'].enhance ['shared_mustache:compile']
end
