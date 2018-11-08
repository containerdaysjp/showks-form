json.extract! project, :id, :username, :github_id, :twitter_id, :comment, :created_at, :updated_at
json.url project_url(project, format: :json)
