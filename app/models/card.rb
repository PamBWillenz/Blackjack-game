class Card < ApplicationRecord
  belongs_to :game
  belongs_to :player

  def blackjack_value
    case rank
    when 'A'
      11
    when 'K', 'Q', 'J'
      10
    else
      rank.to_i
    end
  end
end
