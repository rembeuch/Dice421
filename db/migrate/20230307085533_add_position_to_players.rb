class AddPositionToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :positions, :integer , default: 0
  end
end
