class Game < ApplicationRecord
	has_many :players
	has_many :cards

	# When using Postgres jsonb we store `deck` as native JSON/Array.
	# For safety, coerce legacy text JSON into an Array on initialization.
	after_initialize :ensure_deck_array


	# Suits and ranks for a standard deck
	SUITS = %w[Hearts Diamonds Clubs Spades]
	RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A]

		# Deals two cards to each player and the dealer
		def deal_initial_cards
			# Run the entire initial deal inside a DB row lock so multiple requests
			# can't interleave draws and produce inconsistent deals.
			with_lock do
				# Ensure a persisted deck exists; work on a local copy to avoid
				# repeatedly locking inside draw_card!
				initialize_deck! unless deck.present? && deck.any?
				local_deck = deck.dup
				dealer = dealer()
				players.where(is_dealer: false).each do |player|
					2.times do
						card_data = local_deck.shift
						cards.create!(suit: card_data['suit'], rank: card_data['rank'], value: nil, player: player, face_up: true)
					end
				end
				# Dealer gets one card face up, one face down
				card_data = local_deck.shift
				cards.create!(suit: card_data['suit'], rank: card_data['rank'], value: nil, player: dealer, face_up: true)
				card_data = local_deck.shift
				cards.create!(suit: card_data['suit'], rank: card_data['rank'], value: nil, player: dealer, face_up: false)
				# Persist the shortened deck once
				update!(deck: local_deck)
			end
		end

		# Automates dealer's play: reveal face-down card, hit until hand value >= 17, then stand
			def dealer_play
				dealer = dealer()
				# Reveal dealer's face-down card
				dealer.cards.where(face_up: false).update_all(face_up: true)
				# Dealer hits until hand value >= 17, gets blackjack, or busts
				# Safety: prevent infinite loops by limiting iterations and handling empty deck
				max_iterations = 100
				iterations = 0
				while dealer.hand_value < 17 && !bust?(dealer) && !blackjack?(dealer) && iterations < max_iterations
					break if remaining_deck.empty?
					hit(dealer, face_up: true)
					iterations += 1
				end
				# Only mark standing if dealer isn't already standing
				stand(dealer) unless dealer.standing?
			end

	# Deals one card to the specified player
		def hit(player, face_up: true)
			# Draw a card from the persisted deck with locking to avoid races
			card_data = draw_card!
			return unless card_data
			cards.create!(suit: card_data['suit'], rank: card_data['rank'], value: nil, player: player, face_up: face_up)
		end

	# Returns the remaining cards in the deck (not yet dealt)
	def remaining_deck
		# If we have a persisted deck (jsonb), that represents the remaining ordered cards
		return deck if deck.present?
		# Fallback: compute remaining deck from DB (legacy behavior)
		dealt = cards.pluck(:suit, :rank)
		SUITS.product(RANKS).reject { |suit, rank| dealt.include?([suit, rank]) }
			.map { |suit, rank| { 'suit' => suit, 'rank' => rank } }
	end

	# Initialize and persist a shuffled deck for this game
	def initialize_deck!(shuffle: true)
		initial = SUITS.product(RANKS).map { |suit, rank| { 'suit' => suit, 'rank' => rank } }
		initial.shuffle! if shuffle
		update!(deck: initial)
		deck
	end

	# Atomically draw the next card from the persisted deck and persist the shortened deck
	def draw_card!
		with_lock do
			initialize_deck! unless deck.present? && deck.any?
			return nil if deck.blank?
			card = deck.shift
			update!(deck: deck)
			card
		end
	end

	# Convenience helper to get the dealer player
	def dealer
		players.find_by(is_dealer: true)
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

	def winner?(player)
		dealer = players.find_by(is_dealer: true)
		return false if bust?(player)
		return true if bust?(dealer)
		player.hand_value > dealer.hand_value
	end

	def dealer_winner?
		dealer = players.find_by(is_dealer: true)
		return false if bust?(dealer)
		# Dealer wins if any non-dealer player is not a winner or tie
		non_dealers = players.where(is_dealer: false)
		# Dealer wins if dealer has blackjack or higher hand than all non-busted players
		return true if blackjack?(dealer)
		non_dealers.all? { |p| bust?(p) || dealer.hand_value > p.hand_value }
	end

	def tie?(player)
		dealer = players.find_by(is_dealer: true)
		!bust?(player) && !bust?(dealer) && player.hand_value == dealer.hand_value
	end

	private

	# Builds a standard 52-card deck
	def build_deck
		SUITS.product(RANKS).map { |suit, rank| { suit: suit, rank: rank } }
	end

		# Ensure deck is an Array (parse text JSON for legacy installs)
		def ensure_deck_array
			return if deck.is_a?(Array)
			if deck.nil? || deck == ''
				self.deck = []
			else
				begin
					self.deck = JSON.parse(deck)
				rescue JSON::ParserError
					self.deck = []
				end
			end
		end
end