class AddpreviousPointsToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :previous_points, :integer , default: 0
  end
end
