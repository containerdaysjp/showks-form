FROM ruby:2.3.3

ARG RAILS_MASTER_KEY

ENV APP_ROOT /usr/src/showks-form
ENV PIPELINE_ROOT /usr/src/showks-concourse-pipelines
ENV CANVAS_ROOT /usr/src/showks-canvas

WORKDIR $APP_ROOT

COPY Gemfile Gemfile.lock $APP_ROOT/
RUN apt-get update && \
    apt-get install -y cmake jq mysql-client sqlite3 nodejs npm && \
    npm install -g yarnpkg && \
    bundle install
COPY . $APP_ROOT/
COPY app/assets/showks-concourse-pipelines/ $PIPELINE_ROOT/
COPY app/assets/showks-canvas/ $CANVAS_ROOT/

RUN curl -vL https://github.com/concourse/concourse/releases/download/`curl -s https://api.github.com/repos/concourse/concourse/releases/latest | jq -r .tag_name`/fly_linux_amd64 -o /usr/local/bin/fly &&\
    chmod +x /usr/local/bin/fly

RUN curl -vL https://storage.googleapis.com/spinnaker-artifacts/spin/$(curl -s https://storage.googleapis.com/spinnaker-artifacts/spin/latest)/linux/amd64/spin -o /usr/local/bin/spin && \
    chmod +x /usr/local/bin/spin

RUN env

RUN rake assets:precompile RAILS_ENV=production

EXPOSE 3000
CMD ["rails", "s", "-b", "0.0.0.0"]

