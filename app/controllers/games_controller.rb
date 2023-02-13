class GamesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_player, only: [:new, :create, :show, :leave, :join, :lap, :results]
    def new
        @game = Game.new
    end

    def create
        @game = Game.new
        @game.title = params[:game][:title]
        if @player && @player.in_game == true
            flash[:notice] = "Vous avez une partie en cours !"
            redirect_to root_path
        else
            if @game.save
                if @player.nil?
                    @player = Player.create!(pseudo: params[:game][:pseudo], user: current_user, game: @game)
                    @player.update(in_game: true)
                else 
                    @player.update(pseudo: params[:game][:pseudo], game: @game, in_game: true)
                end
                redirect_to game_path(@game)
            end
        end
    end

    def show
        @game = Game.find(params[:id])
        @players = @game.players.where(in_game: true)
    end

    def leave
        @game = @player.game
        @player.update(in_game: false)
        redirect_to root_path
    end

    def join
        @game = Game.find(params[:game][:game_id])
        if @game.title == params[:game][:title]
            if @player.nil?
                @player = Player.create!(pseudo: params[:game][:pseudo], user: current_user, game: @game)
                @player.update(in_game: true)
            else 
                @player.update(pseudo: params[:game][:pseudo], game: @game, in_game: true)
            end
            redirect_to game_path(@game)
        else
            redirect_to root_path, notice: 'mauvais id ou titre'
        end
    end

    def lap
        @game = Game.find(params[:id])
        if @game.lap_max == 0
            if @game.lap < 3
                @game.update(lap: (@game.lap + 1))
            end
        else  
            if @game.lap < 3 && @game.lap < @game.lap_max
                @game.update(lap: (@game.lap + 1))
            end
        end
    end

    def results
        @player.update(score: params[:score])
    end

    def turn
        @game = Game.find(params[:id])
        if @game.current_player == 0
            @game.lap_max = @game.lap
        end
        @game.update(current_player: @game.current_player + 1, lap: 0)
        redirect_to game_path(@game)
    end

    def reset
        @game = Game.find(params[:id])
        @game.update(lap: 0, lap_max: 0, current_player: 0)
        @players = @game.players.where(in_game: true)
        @players.each do |player| 
            player.update(score: 0)
        end
        redirect_to game_path(@game)
    end

    private

    def set_player
        @player = Player.find_by(user: current_user)
    end
end
