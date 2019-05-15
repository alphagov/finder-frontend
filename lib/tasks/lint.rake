task default: :lint
desc "Run govuk-lint and StandardJS with similar params to CI"
task :lint do
  sh "bundle exec govuk-lint-ruby --format clang app config features Gemfile lib spec"
  sh "yarn run lint"
end
