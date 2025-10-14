module GamesHelper
  # Should we show the betting UI? True at round start when no cards have been dealt.
  def show_betting?(game)
    game.cards.empty?
  end

  # Should we show the players' card area (cards have been dealt)?
  def show_cards?(game)
    game.cards.any?
  end

  # Should we show the New Game button? When the round is over.
  def show_new_game?(game)
    game.game_over?
  end

  # For a dealer player, show dealer's visible value when player is still playing.
  def dealer_visible_value(player, game)
    return player.hand_value if game.player_done?
    player.visible_hand_value
  end

  # Show result badge text for a player (winner/tie/bust) or nil if none.
  def result_badge_for(player, game)
    return 'Winner!' if game.winner?(player)
    return 'Tie!' if game.tie?(player)
    return 'Bust!' if game.bust?(player)
    nil
  end
end

