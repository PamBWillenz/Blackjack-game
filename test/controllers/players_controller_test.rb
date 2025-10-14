require "test_helper"

class PlayersControllerTest < ActionDispatch::IntegrationTest
  test "placing a bet updates player bet and redirects" do
  g = Game.create!
  g.players.create!(name: 'Dealer', is_dealer: true)
  p = g.players.create!(name: 'P', is_dealer: false, balance: 100)

    post bet_player_path(p, amount: 25)
    assert_response :redirect
    p.reload
    assert_equal 25, p.bet
  end

  test "reset balance sets balance to default and redirects" do
    g = Game.create!
    p = g.players.create!(name: 'P', is_dealer: false, balance: 50)
    post reset_balance_player_path(p)
    assert_response :redirect
    p.reload
    assert_equal 300, p.balance
  end
end
