class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.string :username
      t.string :github_id
      t.string :twitter_id
      t.string :comment

      t.timestamps
    end
  end
end
