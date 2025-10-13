class PlayersController < ApplicationController
  def bet
    @player = Player.find(params[:id])
    amount = params[:amount].to_i
    @player.update(bet: amount)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@player, :bet), partial: "players/player_bet", locals: { player: @player }) }
      format.html { redirect_back fallback_location: game_path(@player.game) }
    end
  end
end

