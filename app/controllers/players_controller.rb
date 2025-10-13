class PlayersController < ApplicationController
  def bet
    @player = Player.find(params[:id])
    amount = params[:amount].to_i
    @player.update(bet: amount)

    respond_to do |format|
      dom = helpers.dom_id(@player, :bet)
      # Replace the player's bet frame
      streams = []
      streams << turbo_stream.replace(dom, partial: "players/player_bet", locals: { player: @player })
      # Also replace the deal button frame so its disabled state updates immediately
      deal_dom = helpers.dom_id(@player.game, :deal_button)
      streams << turbo_stream.replace(deal_dom, partial: "games/deal_button", locals: { game: @player.game })
      format.turbo_stream { render turbo_stream: streams }
      format.html { redirect_back fallback_location: game_path(@player.game) }
    end
  end
end

