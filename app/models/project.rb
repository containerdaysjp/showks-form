require 'open3'

class Project < ApplicationRecord
  validates :username, uniqueness: true, presence: true, format: { with: /\A[a-z0-9\-]+\z/}, length: { maximum: 50 }
  validates :github_id, uniqueness: true, presence: true, length: { maximum: 30 } #FIXME: need to check validation rule about github id
  validates :twitter_id, format: { with: /\A[a-zA-Z0-9\_]+\z/}, length: { maximum: 15 }
  validates :comment, length: { maximum: 500 }

  before_create :provision
  before_destroy :cleanup

  private
  def provision
    create_repository
    create_webhook("staging")
    create_webhook("production")
    push_repository
    create_pipeline("staging")
    create_pipeline("production")
    create_spin
  end

  def repository_name
    "showks-canvas-#{self.username}"
  end

  def webhook_token
    "hogefuga"
  end

  def pipeline_path(env)
    "tmp/#{self.username}-#{env}.yaml"
  end

  def create_repository
    @client = Octokit::Client.new(login: Rails.application.credentials.github[:username], password: Rails.application.credentials.github[:password])
    if @client.repository?("containerdaysjp/#{repository_name}")
      @repo = @client.repository("containerdaysjp/#{repository_name}")
    else
      @repo = @client.create_repository(repository_name,{organization: "containerdaysjp"})
    end
  end

  def create_webhook(env)
    @client.create_hook(
        @repo.full_name,
        "web",
        {url: "http://concourse.showks.containerdays.jp/api/v1/teams/main/pipelines/#{self.username}-#{env}/resources/app/check/webhook?webhook_token=#{webhook_token}", content_type: "json"}, #TODO: Should be configurable.
        {events: ["push", "pull_request"], active: true})
  end

  def push_repository
    repository = Rugged::Repository.new("app/assets/showks-canvas")
    auth = Rugged::Credentials::UserPassword.new(username: Rails.application.credentials.github[:username], password: Rails.application.credentials.github[:password])
    remote = repository.remotes.create_anonymous(@repo.clone_url)
    remote.push("refs/heads/master", credentials: auth)
  end

  def create_pipeline(env)
    logger.debug `fly -t form login -c #{Rails.application.credentials.concourse[:url]} \
            -u #{Rails.application.credentials.concourse[:username]} \
            -p #{Rails.application.credentials.concourse[:password]}`
    logger.debug `cp app/assets/showks-concourse-pipelines/showks-canvas-USERNAME/#{env}.yaml #{pipeline_path(env)}`
    logger.debug `sed -i 's/USERNAME/#{self.username}/' #{pipeline_path(env)}`
    File.open("tmp/params.yaml", "w") do |f|
      f.puts(Rails.application.credentials.concourse_params)
    end
    logger.debug `fly -t form set-pipeline -p #{self.username}-#{env} -c #{pipeline_path(env)} -l tmp/params.yaml -n`
    logger.debug `fly -t form unpause-pipeline -p #{self.username}-#{env}`
  end

  def create_spin
    logger.debug Open3.capture3("./deploy-canvas-pipelines.sh #{self.username}",
                                chdir: "app/assets/showks-spinnaker-pipelines/showks-canvas")
  end

  def cleanup
    client = Octokit::Client.new(login: Rails.application.credentials.github[:username], password: Rails.application.credentials.github[:password])
    client.delete_repository("containerdaysjp/#{repository_name}")
    logger.debug system("fly -t form login -c #{Rails.application.credentials.concourse[:url]} \
            -u #{Rails.application.credentials.concourse[:username]} \
            -p #{Rails.application.credentials.concourse[:password]}")
    logger.debug `fly -t form destroy-pipeline -p #{self.username}-staging -n`
    logger.debug `fly -t form destroy-pipeline -p #{self.username}-production -n`
    logger.debug Open3.capture3("./spin --config ./spinconfig application delete showks-canvas-#{self.username}",
                                chdir: "app/assets/showks-spinnaker-pipelines/showks-canvas")
  end

end
