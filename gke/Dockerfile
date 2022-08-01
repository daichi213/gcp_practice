FROM ruby:latest

RUN mkdir -pm 770 /var/www
COPY ./sample_app /var/www/
WORKDIR /var/www/sample_app
RUN chmod 755 -R /var/www/sample_app
RUN gem update
RUN gem install bundler
RUN bundle install

EXPOSE 3000

COPY startup.sh /startup.sh
RUN chmod 744 /startup.sh
CMD ["/startup.sh"]