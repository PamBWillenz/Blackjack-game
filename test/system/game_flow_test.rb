require "application_system_test_case"

class GameFlowTest < ApplicationSystemTestCase
  test "full flow: deal -> player stands -> dealer plays -> new game visible, no deal" do
    # Create game and players via models to set up preconditions
    g = Game.create!
  g.players.create!(name: 'Dealer', is_dealer: true)
    player = g.players.create!(name: 'Player 1', is_dealer: false)

    g.initialize_deck!
    g.deal_initial_cards

    # Force player standing and run dealer
    player.update!(standing: true)
    g.dealer_play

    # Now visit the show page and assert expectations
  visit game_path(g)
  sleep 1.5

    # New Game button should be visible
  assert_selector "button", text: "New Game"

    # Deal Cards button should NOT be present
    assert_no_text "Deal Cards"
    sleep 1.5
  end
end
