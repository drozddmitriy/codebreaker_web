class Racker
  FILE_NAME = 'data.yml'.freeze
  include RenderModule
  include RackerHelper
  include Codebreaker::DatabaseModule
  include Codebreaker::StatisticModule
  attr_reader :request

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    case @request.path
    when '/' then index
    when '/game' then game
    when '/attempt' then attempt
    when '/win' then win
    else response_helper
    end
  end

  def response_helper
    case @request.path
    when '/lose' then lose
    when '/hint' then show_hint
    when '/rules' then rules_view
    when '/statistics' then statistics
    else not_found_view
    end
  end

  def game
    return not_found_view unless (game = start_game)

    @request.session[:game] = game
    game_view
  end

  def start_game
    return game_session if exist?(:game)

    return false if @request.params.empty?

    game = Codebreaker::Game.new
    game.set_code
    game.player = @request.params['player_name']
    @request.session[:win] = false
    @request.session[:attempt_code] = []
    @request.session[:show] = false
    difficulty_player(game)
    game
  end

  def difficulty_player(game)
    case @request.params['level']
    when I18n.t(:easy, scope: [:difficulty]) then game.difficulty_for_player(:easy)
    when I18n.t(:medium, scope: [:difficulty]) then game.difficulty_for_player(:medium)
    when I18n.t(:hell, scope: [:difficulty]) then game.difficulty_for_player(:hell)
    end
  end

  def attempt
    return not_found_view unless exist?(:game)

    Rack::Response.new do |response|
      attempt = @request.params['number']
      game_session.input_code = attempt
      attempt_player(attempt)
      return lose if game_session.diff_try.zero?

      if game_session.win?
        @request.session[:win] = true
        return win
      end
      response.redirect('/game')
    end
  end

  def attempt_player(attempt)
    @request.session[:attempt] = attempt
    @request.session[:attempt_code] = game_session.check
    @request.session[:show_hint] = false
  end

  def show_hint
    Rack::Response.new do |response|
      @request.session[:show_hint] = game_session.hint
      response.redirect('/game')
    end
  end

  def statistics
    @data_stat = sort_player(load)
    statistics_view
  end

  def index
    return game_view if exist?(:game)

    menu_view
  end

  def exist?(param)
    @request.session.key?(param)
  end

  def lose
    return not_found_view unless exist?(:game)

    return redirect_game if game_session.diff_try.positive?

    Rack::Response.new(lose_view) do
      @request.session.clear
    end
  end

  def win
    return not_found_view unless exist?(:game)

    return redirect_game unless @request.session[:win]

    Rack::Response.new(win_view) do
      save(to_hash(game_session), FILE_NAME)
      @request.session.clear
    end
  end

  def game_session
    @request.session[:game]
  end

  def redirect_game
    Rack::Response.new do |response|
      response.redirect('/game')
    end
  end
end
