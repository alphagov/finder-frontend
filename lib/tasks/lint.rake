desc "Run govuk-lint with similar params to CI"
task "lint" do
  sh "bundle exec govuk-lint-ruby --format clang app config features Gemfile lib spec"
end
