# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_10_13_140000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cards", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.string "suit"
    t.string "rank"
    t.integer "value"
    t.bigint "player_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "face_up"
    t.index ["game_id"], name: "index_cards_on_game_id"
    t.index ["player_id"], name: "index_cards_on_player_id"
  end

  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "deck", default: []
  end

  create_table "players", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.string "name"
    t.boolean "is_dealer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "standing"
    t.integer "bet", default: 0, null: false
    t.index ["game_id"], name: "index_players_on_game_id"
  end

  add_foreign_key "cards", "games"
  add_foreign_key "cards", "players"
  add_foreign_key "players", "games"
end
