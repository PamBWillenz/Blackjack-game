
class Player < ApplicationRecord
  belongs_to :game
  has_many :cards

  # Calculates the total value of the player's hand, treating Ace as 1 or 11
  def hand_value
    values = cards.map(&:blackjack_value)
    total = values.sum
    aces = cards.select { |card| card.rank == 'A' }.count

    # Adjust for Aces: subtract 10 for each Ace if total > 21
    while total > 21 && aces > 0
      total -= 10
      aces -= 1
    end
    total
  end

  # Calculates the total value of only face-up cards (used for dealer display before players finish)
  def visible_hand_value
    visible_cards = cards.select { |card| card.face_up }
    values = visible_cards.map(&:blackjack_value)
    total = values.sum
    aces = visible_cards.select { |card| card.rank == 'A' }.count

    while total > 21 && aces > 0
      total -= 10
      aces -= 1
    end
    total
  end
end
