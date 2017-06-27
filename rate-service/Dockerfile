FROM ruby:2.4.1-alpine

ENV WD /var/www/routing-service
ENV HOME /root

RUN apk --update add --virtual build_deps \
    build-base ruby-dev libc-dev linux-headers \
    openssl-dev openssh git libxml2-dev libxslt-dev && \
    apk add tzdata 

# Run Bundle in a cache efficient way
ADD Gemfile* ./
RUN gem install bundler && \
    bundle install --without development test --jobs 4 --retry 5 && \
    apk del build_deps

WORKDIR ${WD}
COPY . $WD

EXPOSE 3002

CMD ["sh", "-c", "rackup config.ru --host 0.0.0.0 -p 3002 -s Puma"]
