class AddStandingToPlayers < ActiveRecord::Migration[7.1]
  def change
    add_column :players, :standing, :boolean
  end
end
