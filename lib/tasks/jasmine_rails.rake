# The jasmine-rails gem isn't loaded in production, so only evaluate
# this code if it's relevant
if Rake::Task.task_defined? 'spec:javascript'
  task default: 'spec:javascript'

  namespace :spec do
    Rake::Task[:javascript].enhance ['shared_mustache:compile']

    Rake::Task[:javascript].enhance do
      Rake::Task['shared_mustache:clean'].invoke
    end
  end
end
