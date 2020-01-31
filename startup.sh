#!/bin/bash

yarn install
bundle check || bundle install

if [[ $1 == "--live" ]] ; then
  GOVUK_APP_DOMAIN=www.gov.uk \
  GOVUK_WEBSITE_ROOT=https://www.gov.uk \
  PLEK_SERVICE_SEARCH_URI=${PLEK_SERVICE_SEARCH_URI-https://www.gov.uk/api} \
  PLEK_SERVICE_CONTENT_STORE_URI=${PLEK_SERVICE_CONTENT_STORE_URI-https://www.gov.uk/api} \
  PLEK_SERVICE_STATIC_URI=${PLEK_SERVICE_STATIC_URI-assets.publishing.service.gov.uk} \
  PLEK_SERVICE_WHITEHALL_FRONTEND_URI=https://www.gov.uk \
  bundle exec rails s -p 3062
else
  GOVUK_WEBSITE_ROOT=localhost:3062 \
  bundle exec rails s -p 3062
fi
