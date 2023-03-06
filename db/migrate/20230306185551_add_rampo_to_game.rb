class AddRampoToGame < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :rampo, :boolean, default: false
  end
end
