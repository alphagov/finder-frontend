desc 'Run all tests'
task :test => [:spec, :cucumber, 'spec:javascript']
