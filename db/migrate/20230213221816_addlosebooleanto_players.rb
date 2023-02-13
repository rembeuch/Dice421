class AddlosebooleantoPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :loser, :boolean, default: false
  end
end
