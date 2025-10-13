
class GamesController < ApplicationController
	def new
		@game = Game.new
	end

		def create
			@game = Game.create
			num_players = params[:game][:number_of_players].to_i
			# Create dealer
			@game.players.create!(name: "Dealer", is_dealer: true)
			# Create players
			num_players.times do |i|
				@game.players.create!(name: "Player #{i+1}", is_dealer: false)
			end
			redirect_to @game
		end

	def show
		@game = Game.find(params[:id])
	end

	def deal
		@game = Game.find(params[:id])
		@game.deal_initial_cards
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
			if @game.players.where(is_dealer: false).all? { |p| p.standing || @game.bust?(p) }
				@game.dealer_play
			end
			redirect_to @game
		end
	private

		def game_params
			params.require(:game).permit(:number_of_players)
		end
end
