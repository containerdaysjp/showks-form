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
    push_repository
    create_pipeline
    create_spin
  end

  def repository_name
    "showks-canvas-#{self.username}"
  end

  def create_repository
    client = Octokit::Client.new(login: Rails.application.credentials.github[:username], password: Rails.application.credentials.github[:password])
    if client.repository?("containerdaysjp/#{repository_name}")
      @repo = client.repository("containerdaysjp/#{repository_name}")
    else
      @repo = client.create_repository(repository_name,{organization: "containerdaysjp"})
    end

    client.create_hook(
        @repo.full_name,
        "web",
        {url: "http://example.com", content_type: "json"}, #TODO: Should be configurable.
        {events: ["push", "pull_request"], active: true})
  end

  def push_repository
    repository = Rugged::Repository.new("/Users/jacopen/workspace/showks/showks-template")
    auth = Rugged::Credentials::UserPassword.new(username: Rails.application.credentials.github[:username], password: Rails.application.credentials.github[:password])
    remote = repository.remotes.create_anonymous(@repo.clone_url)
    remote.push("refs/heads/master", credentials: auth)
  end

  def create_pipeline

  end

  def create_spin

  end

  def cleanup
    client = Octokit::Client.new(login: Rails.application.credentials.github[:username], password: Rails.application.credentials.github[:password])
    client.delete_repository("containerdaysjp/#{repository_name}")
  end

end
