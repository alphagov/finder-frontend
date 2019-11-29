task default: :lint
desc "Run govuk-lint and StandardJS with similar params to CI"
task lint: :environment do
  sh "bundle exec rubocop"
  sh "yarn run lint"
end
