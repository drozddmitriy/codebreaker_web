module RackerHelper
  DEFAULT_PLACEHOLDER = '1234'.freeze
  PLUS = '+'.freeze
  MINUS = '-'.freeze
  NONE = 'x'.freeze

  def disabled_method(game_session)
    game_session.diff_hints.zero?
  end

  def placeholder(request_session, request_session_attempt)
    return DEFAULT_PLACEHOLDER if request_session.empty?

    request_session_attempt
  end

  def show_hint_decorator(request_session_hint)
    return unless request_session_hint

    to_haml = request_session_hint.chars.map { |hint| "%span.badge.badge-light #{hint}\n" }.join
    Haml::Engine.new(to_haml).to_html
  end

  def show_element_decorator(request_session_attempt)
    to_haml = if request_session_attempt.empty?
                (1..4).map { "%button.btn.btn-danger.marks{:disabled => 'disabled', :type => 'button'} #{NONE}\n" }.join
              else
                helper_show_element_decorator(request_session_attempt).join
              end
    Haml::Engine.new(to_haml).to_html
  end

  def helper_show_element_decorator(request_session_attempt)
    request_session_attempt.chars.map do |element|
      if element == PLUS
        "%button.btn.btn-success.marks{:disabled => 'disabled', :type => 'button'} #{PLUS}\n"
      else
        "%button.btn.btn-primary.marks{:disabled => 'disabled', :type => 'button'} #{MINUS}\n"
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
