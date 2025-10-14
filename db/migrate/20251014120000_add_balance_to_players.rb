class AddBalanceToPlayers < ActiveRecord::Migration[7.1]
  def change
    add_column :players, :balance, :integer, default: 300, null: false
  end
end
