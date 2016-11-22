#!/bin/bash
set -x
export DISPLAY=:99
export GOVUK_APP_DOMAIN=test.gov.uk
export GOVUK_ASSET_ROOT=http://static.test.gov.uk
export REPO_NAME="alphagov/finder-frontend"
env

function github_status {
  REPO_NAME="$1"
  STATUS="$2"
  MESSAGE="$3"
  gh-status "$REPO_NAME" "$GIT_COMMIT" "$STATUS" -d "Build #${BUILD_NUMBER} ${MESSAGE}" -u "$BUILD_URL" >/dev/null
}

function error_handler {
  trap - ERR # disable error trap to avoid recursion
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi
  github_status "$REPO_NAME" failure "failed on Jenkins"
  exit "${code}"
}

trap "error_handler ${LINENO}" ERR
github_status "$REPO_NAME" pending "is running on Jenkins"

# This tests that the current branch can be cleanly merged into master
git merge --no-commit origin/master || git merge --abort

bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment --without development

# This is run to ensure that assets precompile
bundle exec rake assets:precompile

# Clone govuk-content-schemas depedency for tests
rm -rf tmp/govuk-content-schemas
git clone --branch deployed-to-production git@github.com:alphagov/govuk-content-schemas.git tmp/govuk-content-schemas

RAILS_ENV=test GOVUK_CONTENT_SCHEMAS_PATH=tmp/govuk-content-schemas bundle exec rake

export EXIT_STATUS=$?

if [ "$EXIT_STATUS" == "0" ]; then
  github_status "$REPO_NAME" success "succeeded on Jenkins"
else
  github_status "$REPO_NAME" failure "failed on Jenkins"
fi

exit $EXIT_STATUS
