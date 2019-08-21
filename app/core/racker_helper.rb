module RackerHelper
  def disabled_method(game_session)
    game_session.diff_hints.zero?
  end

  def placeholder(request_session, request_session_attempt)
    return '1234' if request_session.empty?

    request_session_attempt
  end

  def show_hint_decorator(request_session_hint)
    if request_session_hint
      request_session_hint.each_char do |hint|
        "%span.badge.badge-light= #{hint}"
      end
    end
  end

  def to_hash(game_session)
    date = DateTime.now.strftime('%d/%m/%Y %H:%M:%S')
    game = game_session
    array = [game.player, game.attempts, game.hints_total, game.hints_used, game.difficulty, game.try, date]
    keys = %w[name attempts hints_total hints_used difficulty try date]
    hash = {}
    keys.zip(array) { |key, val| hash[key.to_sym] = val }
    hash
  end
end
