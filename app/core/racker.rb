class Racker
  FILE_NAME = 'data.yml'.freeze
  include RenderModule
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
    when '/lose' then lose
    when '/hint' then show_hint
    when '/rules' then rules_view
    when '/statistics' then statistics
    else error404_view
    end
  end

  def game
    game = start_game
    return error404_view unless game

    @request.session[:game] = game

    game_view
  end

  def start_game
    return game_session if exist?(:game)

    return false if @request.params.empty?

    game = Game.new
    game.set_code
    game.player = @request.params['player_name']
    @request.session[:win] = false
    @request.session[:attempt_code] = []
    @request.session[:show] = false
    case @request.params['level']
    when 'easy' then game.difficulty_player('easy', 15, 2)
    when 'medium' then game.difficulty_player('medium', 10)
    when 'hell' then game.difficulty_player('hell', 5)
    end
    game
  end

  def attempt
    return error404_view unless exist?(:game)

    Rack::Response.new do |response|
      return lose if @request.session[:game].diff_try.zero?

      attempt = @request.params['number']
      game_session.input_code = attempt
      game_session.add_try

      if game_session.win?
        @request.session[:win] = true
        return win
      end

      @request.session[:attempt] = attempt
      @request.session[:attempt_code] = game_session.check
      @request.session[:show_hint] = false
      response.redirect('/game')
    end
  end

  def show_hint
    Rack::Response.new do |response|
      @request.session[:show_hint] = game_session.hint
      response.redirect('/game')
    end
  end

  def statistics
    console = Console.new
    data = console.load
    @data_stat = console.sort_player(data)
    statistics_view
  end

  def index
    return game_view if exist?(:game)

    menu_view
  end

  def exist?(param)
    @request.session.has_key?(param)
  end

  def lose
    return error404_view unless exist?(:game)

    return redirect_game if game_session.diff_try.positive?

    Rack::Response.new(lose_view) do
      @request.session.clear
    end
  end

  def win
    return error404_view unless exist?(:game)

    return redirect_game unless @request.session[:win]

    Rack::Response.new(win_view) do
      Console.new.save(to_hash, FILE_NAME)
      @request.session.clear
    end
  end

  def game_session
    @request.session[:game]
  end

  def to_hash
    date = DateTime.now.strftime('%d/%m/%Y %H:%M:%S')
    game = game_session
    array = [game.player, game.attempts, game.hints_total, game.hints_used, game.difficulty, game.try, date]
    keys = %w[name attempts hints_total hints_used difficulty try date]
    hash = {}
    keys.zip(array) { |key, val| hash[key.to_sym] = val }
    hash
  end

  def redirect_game
    Rack::Response.new do |response|
      response.redirect('/game')
    end
  end
end
