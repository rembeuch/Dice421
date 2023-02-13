class AddInGameToPlayers < ActiveRecord::Migration[7.0]
  def change
    change_column :players, :in_game, :boolean, default: false
  end
end
