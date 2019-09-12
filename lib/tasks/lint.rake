task default: :lint
desc "Run govuk-lint and StandardJS with similar params to CI"
task :lint do
  sh "bundle exec govuk-lint-ruby --format clang"
  sh "yarn run lint"
end
