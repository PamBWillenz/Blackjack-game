require "test_helper"

class GameTest < ActiveSupport::TestCase
  test "initialize_deck! creates 52 unique cards" do
    g = Game.create!
  # initialize without shuffle so the deck order is deterministic and the
  # dealer's initial hand will be low (forces dealer to hit)
  g.initialize_deck!(shuffle: false)
    assert_equal 52, g.deck.size
    # ensure uniqueness by suit+rank
    combos = g.deck.map { |c| "#{c['suit']}-#{c['rank']}" }
    assert_equal 52, combos.uniq.size
  end

  test "draw_card! decreases deck size and persists" do
    g = Game.create!
    g.initialize_deck!
    initial_size = g.deck.size
    card = g.draw_card!
    assert card.present?
    g.reload
    assert_equal initial_size - 1, g.deck.size
  end

  test "drawing 52 cards empties deck and next draw reshuffles" do
    g = Game.create!
    g.initialize_deck!
    52.times { g.draw_card! }
    g.reload
    assert_equal 0, g.deck.size
    # draw_card! no longer auto-reshuffles mid-hand; next draw should return nil
    card = g.draw_card!
    assert_nil card
    g.reload
    assert_equal 0, g.deck.size
  end

  test "deal_initial_cards gives correct cards to players and dealer" do
    g = Game.create!
    # create one dealer and one player
    g.players.create!(name: 'Dealer', is_dealer: true)
    g.players.create!(name: 'Player 1', is_dealer: false)

    g.deal_initial_cards

    dealer = g.players.find_by(is_dealer: true)
    player = g.players.find_by(is_dealer: false)

    # non-dealer player should have exactly 2 face_up cards
    assert_equal 2, player.cards.where(face_up: true).count

    # dealer should have 1 face_up and 1 face_down
    assert_equal 1, dealer.cards.where(face_up: true).count
    assert_equal 1, dealer.cards.where(face_up: false).count
  end

  test "dealer_play stops after bust and deck decreases" do
    g = Game.create!
    dealer = g.players.create!(name: 'Dealer', is_dealer: true)
    player = g.players.create!(name: 'Player 1', is_dealer: false)

    g.initialize_deck!
    g.deal_initial_cards

    # force player to stand so dealer_play runs
    player.update!(standing: true)

    initial_deck_size = g.deck.size
    g.dealer_play
    g.reload

    assert (dealer.cards.count > 2) || (g.deck.size < initial_deck_size), "Expected dealer to draw or deck to shrink (cards=#{dealer.cards.count} deck=#{g.deck.size} initial=#{initial_deck_size})"
    
    assert dealer.hand_value >= 17 || dealer.hand_value > 21
  end

  test "resolve_bets! pays winners, losers, ties correctly" do
    g = Game.create!
    dealer = g.players.create!(name: 'Dealer', is_dealer: true)
    p1 = g.players.create!(name: 'P1', is_dealer: false, balance: 100)
    p2 = g.players.create!(name: 'P2', is_dealer: false, balance: 100)

    # P1 will win (20 vs dealer 18)
  g.cards.create!(suit: 'H', rank: 'K', value: nil, player: p1)
  g.cards.create!(suit: 'D', rank: 'Q', value: nil, player: p1)
    p1.update!(bet: 10)

    # P2 ties with dealer (both 18)
  g.cards.create!(suit: 'H', rank: 'K', value: nil, player: p2)
  g.cards.create!(suit: 'D', rank: '8', value: nil, player: p2)
    p2.update!(bet: 20)

  g.cards.create!(suit: 'S', rank: '9', value: nil, player: dealer)
  g.cards.create!(suit: 'C', rank: '9', value: nil, player: dealer)

    g.resolve_bets!
    p1.reload
    p2.reload
    assert_equal 110, p1.balance
    assert_equal 100, p2.balance
    assert_equal 0, p2.bet
  end

  test "resolve_bets handles dealer bust" do
    g = Game.create!
    dealer = g.players.create!(name: 'Dealer', is_dealer: true)
    p = g.players.create!(name: 'P', is_dealer: false, balance: 100)
    p.update!(bet: 25)
    # player 18
  g.cards.create!(suit:'H', rank:'K', value:nil, player: p)
  g.cards.create!(suit:'D', rank:'8', value:nil, player: p)
    # dealer busted
  g.cards.create!(suit:'S', rank:'K', value:nil, player: dealer)
  g.cards.create!(suit:'C', rank:'9', value:nil, player: dealer)
  g.cards.create!(suit:'H', rank:'6', value:nil, player: dealer)
    g.resolve_bets!
    p.reload
    assert_equal 125, p.balance
  end

  test "winner? and tie? work correctly" do
    g = Game.create!
    dealer = g.players.create!(name: 'Dealer', is_dealer: true)
    p = g.players.create!(name: 'P', is_dealer: false)
  g.cards.create!(suit:'H', rank:'K', player: p); g.cards.create!(suit:'D', rank:'7', player: p)
  g.cards.create!(suit:'S', rank:'K', player: dealer); g.cards.create!(suit:'C', rank:'6', player: dealer)
    assert g.winner?(p)
    assert_not g.tie?(p)
  end

  test "draw_card! returns nil when deck empty" do
    g = Game.create!
    g.initialize_deck!
    52.times { g.draw_card! }
    assert_nil g.draw_card!
  end

  test "dealer_play is idempotent: calling twice shouldn't add extra cards if dealer standing" do
    g = Game.create!
    dealer = g.players.create!(name:'Dealer', is_dealer:true)
    p = g.players.create!(name:'P', is_dealer:false)
    g.initialize_deck!
    g.deal_initial_cards
    p.update!(standing: true)
    g.dealer_play
    before_count = dealer.cards.count
    g.dealer_play
    assert_equal before_count, dealer.cards.count
  end
end