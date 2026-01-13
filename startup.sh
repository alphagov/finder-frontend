#!/bin/bash

yarn install
bundle check || bundle install

if [[ $1 == "--live" ]] ; then
  GOVUK_APP_DOMAIN=www.gov.uk \
  GOVUK_WEBSITE_ROOT=https://www.gov.uk \
  PLEK_SERVICE_SEARCH_API_URI=${PLEK_SERVICE_SEARCH_API_URI-https://www.gov.uk/api} \
  PLEK_SERVICE_SEARCH_API_V2_URI=${PLEK_SERVICE_SEARCH_API_V2_URI-https://search.publishing.service.gov.uk/v0_1} \
  PLEK_SERVICE_CONTENT_STORE_URI=${PLEK_SERVICE_CONTENT_STORE_URI-https://www.gov.uk/api} \
  PLEK_SERVICE_WHITEHALL_FRONTEND_URI=https://www.gov.uk \
  ./bin/dev
else
  echo "ERROR: other startup modes are not supported"
  echo ""
  echo "https://docs.publishing.service.gov.uk/manual/local-frontend-development.html"
  exit 1
fi
