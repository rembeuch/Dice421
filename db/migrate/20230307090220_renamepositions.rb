class Renamepositions < ActiveRecord::Migration[7.0]
  def change
    rename_column :players, :positions, :position
  end
end
