class AddPseudoToplayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :pseudo, :string
  end
end
