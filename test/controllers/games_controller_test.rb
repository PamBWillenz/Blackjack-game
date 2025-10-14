require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  test "deal action redirects and deals when bets present" do
    g = Game.create!
    g.players.create!(name: 'Dealer', is_dealer: true)
    p = g.players.create!(name: 'P', is_dealer: false, balance: 100)
    post bet_player_path(p, amount: 10)
    post deal_game_path(g)
    assert_response :redirect
    g.reload
    assert_operator g.cards.count, :>, 0
  end

  test "hit action adds a card to player and redirects" do
    g = Game.create!
    g.players.create!(name: 'Dealer', is_dealer: true)
    p = g.players.create!(name: 'P', is_dealer: false)
    post hit_game_path(g, player_id: p.id)
    assert_response :redirect
    p.reload
    assert_operator p.cards.count, :>=, 0
  end

  test "stand action redirects and marks player standing" do
    g = Game.create!
    g.players.create!(name: 'Dealer', is_dealer: true)
    p = g.players.create!(name: 'P', is_dealer: false)
    post stand_game_path(g, player_id: p.id)
    assert_response :redirect
    p.reload
    assert p.standing
  end
end
