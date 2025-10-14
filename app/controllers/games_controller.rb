
class GamesController < ApplicationController
	def new
		@game = Game.new
	end

		def create
			@game = Game.create
			# Create dealer and a single human player, preserving previous player's balance/bet if available
			@game.players.create!(name: "Dealer", is_dealer: true)
			last_player = Player.where(is_dealer: false).order(updated_at: :desc).first
			if last_player
				@game.players.create!(name: "Player 1", is_dealer: false, balance: last_player.balance, bet: last_player.bet)
			else
				@game.players.create!(name: "Player 1", is_dealer: false)
			end
			redirect_to @game
		end

	def show
		@game = Game.find(params[:id])
	end

	def deal
		@game = Game.find(params[:id])
		# Prevent dealing after the round is over
		@game.deal_initial_cards unless @game.game_over?
		redirect_to @game
	end

		def hit
			@game = Game.find(params[:id])
			@player = Player.find(params[:player_id])
			@game.hit(@player)
			# If player busts, mark as standing
			if @game.bust?(@player)
				@game.stand(@player)
			end
			players_done?
		end

		def stand
			@game = Game.find(params[:id])
			@player = Player.find(params[:player_id])
			@game.stand(@player)
			players_done?
		end

		def players_done?
			# Check if all non-dealer players are done
			# Use the single-player helper; keep compatibility with older multi-player games
			if @game.player_done?
				# Only trigger dealer_play if the game hasn't already been completed
				@game.dealer_play unless @game.game_over?
			end

			def new_round
				@game = Game.find(params[:id])
				# destroy existing cards and reset player standing/bets but preserve balance
				@game.cards.destroy_all
				@game.players.each do |p|
					p.update!(standing: false, bet: 0)
				end
				# render the show partial HTML so client JS or Stimulus can replace the game container
				render partial: 'games/show', locals: { game: @game }
			end
			redirect_to @game
		end
	private

		def game_params
			params.require(:game).permit(:number_of_players)
		end
end
