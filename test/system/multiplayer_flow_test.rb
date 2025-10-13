require "application_system_test_case"

class MultiplayerFlowTest < ApplicationSystemTestCase
  test "one player busts while others stand -> dealer plays -> UI shows New Game" do
    g = Game.create!
    g.players.create!(name: 'Dealer', is_dealer: true)
    p1 = g.players.create!(name: 'Player 1', is_dealer: false)
    p2 = g.players.create!(name: 'Player 2', is_dealer: false)

    g.initialize_deck!
    g.deal_initial_cards
      sleep 1.0

    # Make p1 hit until bust
    while !g.bust?(p1)
      g.hit(p1)
      p1.reload
      break if p1.cards.count > 10 # safety
    end

    # p2 stands
    p2.update!(standing: true)

    # run dealer
    g.dealer_play

    visit game_path(g)
      sleep 1.5

    assert_selector "form", text: "New Game"
    assert_no_text "Deal Cards"
    # After game over, winner/bust badges should be visible
    assert_text "Bust!"
  end

  test "multiple players stand -> dealer plays -> New Game visible and winners shown" do
    g = Game.create!
    g.players.create!(name: 'Dealer', is_dealer: true)
    p1 = g.players.create!(name: 'Player 1', is_dealer: false)
    p2 = g.players.create!(name: 'Player 2', is_dealer: false)

    g.initialize_deck!
    g.deal_initial_cards

    # both players stand
    p1.update!(standing: true)
    p2.update!(standing: true)

    g.dealer_play

    visit game_path(g)
      sleep 1.5

    assert_selector "form", text: "New Game"
    assert_no_text "Deal Cards"
    # At least one winner or tie/bust badge should be present after game over
    assert (has_text?("Winner!") || has_text?("Tie!") || has_text?("Bust!")), "Expected some outcome badge"
  end
end
