#!/usr/bin/env ruby
# Quick repro script to run the Blackjack flow and print debug-style messages.
# Run with: bin/rails runner script/repro_dealer_bust.rb

puts "Starting repro_dealer_bust at #{Time.now}"

# When run with `bin/rails runner`, Rails and the app environment are already loaded.
g = Game.create!
dealer = g.players.create!(name: 'Dealer', is_dealer: true)
player = g.players.create!(name: 'Player 1', is_dealer: false)

puts "[script] created game=#{g.id} dealer=#{dealer.id} player=#{player.id}"

puts "[script] calling initialize_deck!"
g.initialize_deck!
g.reload
puts "[script] deck size after initialize: #{g.deck.size}"

puts "[script] calling deal_initial_cards"
g.deal_initial_cards
g.reload
puts "[script] deck size after initial deal: #{g.deck.size}"
puts "[script] cards counts: player=#{player.reload.cards.count} dealer=#{dealer.reload.cards.count}"

puts "[script] forcing player to stand"
player.update!(standing: true)

puts "[script] calling dealer_play"
g.dealer_play
g.reload
puts "[script] after dealer_play: dealer cards=#{dealer.reload.cards.count} deck_remaining=#{g.deck.size}"
puts "[script] dealer hand value=#{dealer.hand_value}"

puts "Done"
