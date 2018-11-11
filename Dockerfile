FROM ruby:2.3.3

ENV APP_ROOT /usr/src/showks-form

WORKDIR $APP_ROOT

COPY Gemfile Gemfile.lock $APP_ROOT/
RUN apt-get update && apt-get install -y cmake jq nodejs mysql-client sqlite3 && bundle install
COPY . $APP_ROOT/

RUN curl -vL https://github.com/concourse/concourse/releases/download/`curl -s https://api.github.com/repos/concourse/concourse/releases/latest | jq -r .tag_name`/fly_linux_amd64 -o /usr/local/bin/fly &&\
    chmod +x /usr/local/bin/fly

RUN curl -vL https://storage.googleapis.com/spinnaker-artifacts/spin/$(curl -s https://storage.googleapis.com/spinnaker-artifacts/spin/latest)/linux/amd64/spin -o /usr/local/bin/spin && \
    chmod +x /usr/local/bin/spin

EXPOSE 3000
CMD ["rails", "s", "-b", "0.0.0.0"]