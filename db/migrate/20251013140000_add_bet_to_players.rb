class AddBetToPlayers < ActiveRecord::Migration[7.1]
  def change
    add_column :players, :bet, :integer, default: 0, null: false
  end
end
