module RackerHelper
  def disabled_method(game_session)
    game_session.diff_hints.zero?
  end

  def placeholder(request_session, request_session_attempt)
    return '1234' if request_session.empty?

    request_session_attempt
  end

  def show_hint_decorator(request_session_hint)
    return unless request_session_hint

    str = ''
    request_session_hint.each_char do |hint|
      str << "%span.badge.badge-light #{hint}\n"
    end
    Haml::Engine.new(str).to_html
  end

  def show_element_decorator(request_session_attempt)
    str = ''
    if request_session_attempt.empty?
      4.times do
        str << "%button.btn.btn-danger.marks{:disabled => 'disabled', :type => 'button'} x\n"
      end
    else
      request_session_attempt.each_char do |el|
        str << "%button.btn.btn-success.marks{:disabled => 'disabled', :type => 'button'} +\n" if el == '+'
        str << "%button.btn.btn-primary.marks{:disabled => 'disabled', :type => 'button'} -\n" if el == '-'
      end
    end
    Haml::Engine.new(str).to_html
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
