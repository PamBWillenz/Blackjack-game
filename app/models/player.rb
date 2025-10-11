
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
end
