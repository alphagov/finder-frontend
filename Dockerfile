FROM ruby:2.7.2
RUN apt-get update -qq && apt-get upgrade -y
RUN apt-get install -y build-essential nodejs npm && apt-get clean
RUN npm install --global yarn
RUN gem install foreman

ENV GOVUK_APP_NAME finder-frontend
ENV PORT 3062
ENV RAILS_ENV development

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD package.json $APP_HOME/
ADD yarn.lock $APP_HOME/
RUN yarn install --production=true --frozen-lockfile

ADD Gemfile* $APP_HOME/
ADD .ruby-version $APP_HOME/
RUN bundle install

ADD . $APP_HOME

RUN GOVUK_APP_DOMAIN=www.gov.uk GOVUK_WEBSITE_ROOT=http://www.gov.uk RAILS_ENV=production bundle exec rails assets:precompile

HEALTHCHECK CMD curl --silent --fail localhost:$PORT/healthcheck/ready || exit 1

CMD foreman run web
