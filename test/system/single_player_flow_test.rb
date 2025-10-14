require "application_system_test_case"

class SinglePlayerFlowTest < ApplicationSystemTestCase
  test "player busts -> dealer plays -> UI shows New Game" do
    g = Game.create!
    g.players.create!(name: 'Dealer', is_dealer: true)
    player = g.players.create!(name: 'Player 1', is_dealer: false)

    g.initialize_deck!
    g.deal_initial_cards
    sleep 0.5

    # Make player hit until bust (or safety)
    while !g.bust?(player)
      g.hit(player)
      player.reload
      break if player.cards.count > 10
    end

    # run dealer
    g.dealer_play

    visit game_path(g)
    sleep 1.0

    assert_selector "form", text: "New Game"
    assert_no_text "Deal Cards"
    assert_text "Bust!"
  end

  test "player stands -> dealer plays -> winner or tie shown" do
    g = Game.create!
    g.players.create!(name: 'Dealer', is_dealer: true)
    player = g.players.create!(name: 'Player 1', is_dealer: false)

    g.initialize_deck!
    g.deal_initial_cards

    # player stands
    player.update!(standing: true)

    g.dealer_play

    visit game_path(g)
    sleep 1.0

    assert_selector "form", text: "New Game"
    assert_no_text "Deal Cards"
    assert (has_text?("Winner!") || has_text?("Tie!") || has_text?("Bust!")), "Expected some outcome badge"
  end
end
