class GamesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_player, only: [:new, :create, :show, :leave, :join, :lap, :results, :reset, :rampo]
    before_action :redirect_rampo, only: [:show]
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
                    @player.update(pseudo: params[:game][:pseudo], game: @game, in_game: true, score: 0, points: 0, position: 1)
                end
                redirect_to game_path(@game)
            end
        end
    end

    def show
        @game = Game.find(params[:id])
        @players = @game.players.where(in_game: true).sort_by(&:position)
        if @game.lap == 0 && @player.score > 0 && @players[@game.current_player] == @player
            @game.update(lap: 3)
        end
        @unsort_players = @game.players.where(in_game: true)
        @minimum = @players.minimum(:points)
        @maximum = @players.maximum(:points)
        if @minimum > 0 && @unsort_players.where(points: @minimum).count > 1
            jugement
        end
    end

    def leave
        @game = @player.game
        if @game.players.where(in_game: true).sort_by(&:position)[@game.current_player] == @player
            @game.update(lap: 0)
        end
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
                if params[:game][:game_id].to_i != @player.game.id
                    @player.update(score: 0, points: 0)
                end
                @player.update(pseudo: params[:game][:pseudo], game: @game, in_game: true, position: (@game.players.where(in_game: true).maximum(:position)+ 1))
            end
            redirect_to game_path(@game)
        else
            redirect_to root_path, notice: 'mauvais id ou titre'
        end
    end

    def lap
    end
    
    def results
        @player.update(score: params[:score])
        if @player.score == 122
            @player.update(nenette: (@player.nenette += 1))
        end
        @game = @player.game
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

    def turn
        @game = Game.find(params[:id])
        if @game.current_player == 0
            @game.update(lap_max: @game.lap)
        end
        @game.update(current_player: @game.current_player + 1, lap: 0)
        if @game.current_player == (@game.players.where(in_game: true).count -1)
            finish
        end
        redirect_to game_path(@game)
    end

    def reset
        @player.update(reset: true)
        @game = Game.find(params[:id])
        if @game.players.where(in_game: true, reset: true).count > 1
            @loser = Player.find_by(pseudo: params[:loser])
            @loser.update(position: 0, score: 0, points: 0, loser: false, reset: false, nenette: 0)
            @game.update(lap: 0, lap_max: 0, current_player: 0)
            @players = @game.players.where(in_game: true)
            i = 1
            @players.each do |player| 
                if player.id != @loser.id
                    player.update(score: 0, points: 0, loser: false, position: i, reset: false, nenette: 0)
                    i += 1
                end
            end
            if @game.title.include?("rampo-")
                id = @game.title.split("-").last.to_i
                Game.find(id).players.each do |player|
                    player.update(score: 0, points: 0, loser: false, reset: false, position: 1, nenette: 0)
                end
                @players.each do |player|
                    player.update(game: Game.find(id))
                end
                @game.update(rampo: true)
                Game.find(id).update(lap_max: 0, current_player: 0, lap: 0, rampo: false)
                redirect_to game_path(id)
            else
                redirect_to game_path(@game)
            end
        end 
    end

    def finish
        @players = @game.players.where(in_game: true)
        @players.each do |player|
            player_score = player.score.to_s.each_char.each_slice(1).map{|x| x.join}
            player.update(points: calculate_tokens(player_score))
        end
    end

    def calculate_tokens(hand)
        tokens = 0
        aces = hand.count("1")
        sixes = hand.count("6")
        fives = hand.count("5")
        fours = hand.count("4")
        threes = hand.count("3")
        twos = hand.count("2")
      
        if hand == ["1","2","4"]
          tokens += 8
        elsif hand == ["1","1","1"]
          tokens += 7
        elsif aces >= 2 && sixes >= 1 || hand == ["6","6","6"]
          tokens += 6
        elsif aces >= 2 && fives >= 1 || hand == ["5","5","5"]
          tokens += 5
        elsif aces >= 2 && fours >= 1 || hand == ["4","4","4"]
          tokens += 4
        elsif aces >= 2 && threes >= 1 || hand == ["3","3","3"]
          tokens += 3
        elsif aces >= 2 && twos >= 1 || hand == ["2","2","2"]
          tokens += 2
        elsif (hand.include?("1") && hand.include?("2") && hand.include?("3")) ||
              (hand.include?("2") && hand.include?("3") && hand.include?("4")) ||
              (hand.include?("3") && hand.include?("4") && hand.include?("5")) ||
              (hand.include?("4") && hand.include?("5") && hand.include?("6"))
          tokens += 2
        else
          tokens += 1
        end
      
        tokens
    end
      
    def jugement
        @losers = @unsort_players.where(points: @minimum)
        if @minimum == 1
            @losers.each do |loser|
                loser.update(score: loser.score.to_s.reverse.to_i)
            end
            @losers.where(score: @losers.minimum(:score)).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
        elsif @minimum == 2
            @losers.where(score: 123).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
            @losers.where(score: 234).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
            @losers.where(score: 345).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
            @losers.where(score: 456).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
            @losers.where(score: 222).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
            @losers.where(score: 112).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
        elsif @minimum == 3
            @losers.where(score: 333).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
            @losers.where(score: 113).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
        elsif @minimum == 4
            @losers.where(score: 444).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
            @losers.where(score: 114).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
        elsif @minimum == 5
            @losers.where(score: 555).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
            @losers.where(score: 115).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
        elsif @minimum == 6
            @losers.where(score: 666).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
            @losers.where(score: 116).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
        elsif @minimum == 7
            @losers.where(score: 111).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
        elsif @minimum == 8
            @losers.where(score: 124).each do |player|
                player.update(loser: true)
            end
            return if @losers.where(loser: true).count == 1
        end
        if  @losers.where(loser: true).count > 1 && @game.rampo == false
           rampo
        end
    end

    def rampo
        @game.update(rampo: true)
        @rampogame = Game.new
        if @game.previous_points == 0
            @rampogame.title = "rampo-#{@game.id}"
        else
            @rampogame.title = "bis#{@game.title}"
        end
        @rampogame.rampo = false
        @rampogame.lap = 0
        @rampogame.lap_max = 1
        @rampogame.current_player = 0
        @rampogame.previous_points = @players.maximum(:points) + @game.previous_points
            if @rampogame.save
                i = 0
                @losers.where(loser: true).sort_by(&:position).reverse.each do |loser|
                    loser.update(game: @rampogame, score: 0, loser: false, points: 0, position: i)
                    i += 1
                end
            end
    end

    
    private
    
    def set_player
        @player = Player.find_by(user: current_user)
    end

    def redirect_rampo
        @game = Game.find(params[:id])
        if @game.rampo == true && @game != @player.game
            redirect_to game_path(@player.game)
        end
    end
end
