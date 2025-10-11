class Game < ApplicationRecord
	has_many :players
	has_many :cards

	# Suits and ranks for a standard deck
	SUITS = %w[Hearts Diamonds Clubs Spades]
	RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A]

	# Deals two cards to each player and the dealer
	def deal_initial_cards
		deck = build_deck.shuffle
		players.each do |player|
			2.times do
				card_data = deck.pop
				cards.create!(suit: card_data[:suit], rank: card_data[:rank], value: nil, player: player)
			end
		end
		# Dealer is a player with is_dealer: true
		dealer = players.find_by(is_dealer: true)
		if dealer
			2.times do
				card_data = deck.pop
				cards.create!(suit: card_data[:suit], rank: card_data[:rank], value: nil, player: dealer)
			end
		end
	end

	# Deals one card to the specified player
	def hit(player)
		deck = remaining_deck
		card_data = deck.sample
		cards.create!(suit: card_data[:suit], rank: card_data[:rank], value: nil, player: player)
	end

	# Returns the remaining cards in the deck (not yet dealt)
	def remaining_deck
		dealt = cards.pluck(:suit, :rank)
		SUITS.product(RANKS).reject { |suit, rank| dealt.include?([suit, rank]) }
			.map { |suit, rank| { suit: suit, rank: rank } }
	end

  	# Returns true if the player's hand value exceeds 21
	def bust?(player)
		player.hand_value > 21
	end

	# Returns true if the player has blackjack (hand value 21 with two cards)
	def blackjack?(player)
		player.hand_value == 21 && player.cards.count == 2
	end

  # Marks the player as standing (no more cards)
	def stand(player)
		player.update(standing: true)
	end

	private

	# Builds a standard 52-card deck
	def build_deck
		SUITS.product(RANKS).map { |suit, rank| { suit: suit, rank: rank } }
	end
end
