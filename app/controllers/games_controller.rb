
class GamesController < ApplicationController
	def new
		@game = Game.new
	end

		def create
			@game = Game.create
			# Create dealer and a single human player
			@game.players.create!(name: "Dealer", is_dealer: true)
			@game.players.create!(name: "Player 1", is_dealer: false)
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
			redirect_to @game
		end
	private

		def game_params
			params.require(:game).permit(:number_of_players)
		end
end
