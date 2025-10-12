class AddFaceUpToCards < ActiveRecord::Migration[7.1]
  def change
    add_column :cards, :face_up, :boolean
  end
end
