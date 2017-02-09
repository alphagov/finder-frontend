task default: 'jasmine:test'

namespace :jasmine do
  desc "Run JavaScript tests"
  task test: :environment do
    Rake::Task["shared_mustache:compile"].invoke
    Rake::Task["spec:javascript"].invoke
    Rake::Task["shared_mustache:clean"].invoke
  end
end
