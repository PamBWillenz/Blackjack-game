require "application_system_test_case"

class BetAndRoundFlowTest < ApplicationSystemTestCase
  test "place bet enables Deal button and deal proceeds" do
    g = Game.create!
  g.players.create!(name: 'Dealer', is_dealer: true)
  g.players.create!(name: 'Player 1', is_dealer: false)

    visit game_path(g)

    # Initially Deal button should be present but disabled (no bet)
    assert_selector "button", text: "Deal Cards"

    # Place a $10 bet by clicking the chip button within the betting section
    within '#betting-section' do
      first('button', text: '10').click
    end

    sleep 0.5

    # After placing a bet, Deal button should be enabled and clicking it deals cards
    click_on "Deal Cards"
    sleep 0.5

    # Expect player to have cards shown
    assert_selector ".player-cards-container .card-front", minimum: 2
  end

  test "full round: bet -> deal -> hit -> stand -> resolve -> new game visible" do
    g = Game.create!
  g.players.create!(name: 'Dealer', is_dealer: true)
  g.players.create!(name: 'Player 1', is_dealer: false)

    visit game_path(g)
    within '#betting-section' do
      first('button', text: '25').click
    end
    sleep 0.25
    click_on "Deal Cards"
    sleep 0.5

    # Wait for action buttons to appear, then Hit once.
    assert_selector "button", text: "Hit", wait: 2
    click_on "Hit"
    sleep 0.25

    # If Stand is available (player didn't bust), click it; otherwise proceed
    if has_button?('Stand')
      click_on 'Stand'
    end
    sleep 0.5

    # Dealer should play and then New Game button visible (either after stand or bust)
    assert_selector "button", text: "New Game"
  end
end
