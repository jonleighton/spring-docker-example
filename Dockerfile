FROM ruby:2.3
RUN apt-get update -qq && apt-get install -y nodejs

# We need the spring socket file to be readable by the local user on the host,
# so we need to set up a user account with the same UID. Change this if your
# UID is not 1000. Obviously there are ways to make this more flexible (build
# args etc).
RUN useradd --create-home --user-group --uid 1000 app

RUN mkdir /app && chown -R app:app /app
WORKDIR /app
USER app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install

ADD . /app
