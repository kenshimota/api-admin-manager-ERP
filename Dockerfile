FROM ruby:3.0.2-alpine

RUN apk update
RUN apk upgrade --no-cache
RUN apk --update add build-base nodejs tzdata postgresql-dev postgresql-client libxslt-dev libxml2-dev imagemagick

WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN RAILS_ENV=production bundle install

COPY . /myapp
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
