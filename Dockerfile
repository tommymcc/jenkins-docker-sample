FROM ruby:2.4.1-alpine

# Update and install base packages
RUN apk update && \
    apk upgrade && \
    apk add ruby-dev build-base mariadb-dev && \
    rm -rf /var/cache/apk/*

WORKDIR /usr/src/app
COPY Gemfile* ./
RUN bundle install
COPY . .

EXPOSE 3000
CMD ["rails", "-s"]