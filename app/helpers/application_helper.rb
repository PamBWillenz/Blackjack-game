module ApplicationHelper
	# Return a simple suit symbol for the given suit name.
	# Accepts the string names stored on Card.suit like 'Hearts', 'Spades', etc.
	def suit_symbol(suit)
		case suit.to_s
		when 'Hearts' then '♥'
		when 'Diamonds' then '♦'
		when 'Clubs' then '♣'
		when 'Spades' then '♠'
		else suit.to_s
		end
	end

	# Return a Tailwind color class for the suit. Use red for hearts/diamonds.
	def suit_color_class(suit)
		case suit.to_s
		when 'Hearts', 'Diamonds'
			'text-red-600'
		when 'Clubs', 'Spades'
			'text-gray-900'
		else
			'text-current'
		end
	end
end
