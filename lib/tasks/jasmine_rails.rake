# The jasmine-rails gem isn't loaded in production, so only evaluate
# this code if it's relevant
if Rake::Task.task_defined? "spec:javascript"
  task default: "spec:javascript"
end
