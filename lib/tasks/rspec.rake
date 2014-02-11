if Gem.loaded_specs.include?("rspec")
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
end