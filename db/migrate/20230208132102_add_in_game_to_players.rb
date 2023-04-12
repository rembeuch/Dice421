class AddInGameToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :in_game, :boolean, default: false
  end
end
