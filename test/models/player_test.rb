require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  test "card blackjack_value returns expected numeric values" do
    c1 = Card.new(rank: 'A')
    assert_equal 11, c1.blackjack_value
    c2 = Card.new(rank: 'K')
    assert_equal 10, c2.blackjack_value
    c3 = Card.new(rank: '7')
    assert_equal 7, c3.blackjack_value
  end

  test "hand_value handles multiple aces correctly" do
    g = Game.create!
    p = g.players.create!(name: 'P', is_dealer: false)
  g.cards.create!(suit: 'Hearts', rank: 'A', value: nil, player: p)
  g.cards.create!(suit: 'Spades', rank: 'A', value: nil, player: p)
  g.cards.create!(suit: 'Clubs', rank: '9', value: nil, player: p)
    assert_equal 21, p.hand_value

    # A, A, A, 9 -> 12
  p.cards.destroy_all
  g.cards.create!(suit: 'H', rank: 'A', value: nil, player: p)
  g.cards.create!(suit: 'D', rank: 'A', value: nil, player: p)
  g.cards.create!(suit: 'C', rank: 'A', value: nil, player: p)
  g.cards.create!(suit: 'S', rank: '9', value: nil, player: p)
  p.reload
  assert_equal 12, p.hand_value
  end

  test "place_bet clamps to balance and non-negative, apply_result updates balance" do
    g = Game.create!
    p = g.players.create!(name: 'P', is_dealer: false, balance: 100)
    p.place_bet(50)
    assert_equal 50, p.bet
    p.apply_result(50) # win
    p.reload
    assert_equal 150, p.balance
    assert_equal 0, p.bet

    p.place_bet(200)
    assert_equal 150, p.bet # clamped to balance
    p.place_bet(-10)
    assert_equal 0, p.bet
  end
end
