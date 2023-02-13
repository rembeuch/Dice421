class AddTitleToGame < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :title, :string
  end
end
