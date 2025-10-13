class AddDeckJsonbToGames < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:games, :deck)
      add_column :games, :deck, :jsonb, default: []
    end
  end
end
