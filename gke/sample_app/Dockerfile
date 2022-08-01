FROM ruby:latest

# For wait for DB starting
ARG ARG_COMPOSE_WAIT_VER=2.7.3
RUN curl -SL https://github.com/ufoscout/docker-compose-wait/releases/download/${ARG_COMPOSE_WAIT_VER}/wait -o /wait
RUN chmod +x /wait

# For Rails
RUN mkdir -pm 770 /var/www/sample_app
WORKDIR /var/www/sample_app
COPY Gemfile /var/www/sample_app/Gemfile
COPY Gemfile.lock /var/www/sample_app/Gemfile.lock
RUN gem update
RUN gem install bundler
RUN bundle install

EXPOSE 3000

# Start the main process.
# CMD ["rails", "server", "-b", "0.0.0.0"]

# COPY startup.sh /startup.sh
# RUN chmod 744 /startup.sh
# CMD ["/startup.sh"]