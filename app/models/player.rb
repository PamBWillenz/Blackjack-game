
class Player < ApplicationRecord
  belongs_to :game
  has_many :cards, dependent: :destroy

  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  # Place a bet for the player. Ensures bet does not exceed balance.
  def place_bet(amount)
    amt = amount.to_i
    amt = 0 if amt < 0
    amt = [amt, balance].min
    update!(bet: amt)
  end

  # NOTE: balance default is provided by the DB migration (default: 300)

  # Adjust balance by amount (positive = win, negative = loss) and reset bet
  def apply_result(amount)
    update!(balance: balance + amount, bet: 0)
  end

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
