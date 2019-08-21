module RenderModule
  def menu_view
    Rack::Response.new(render('menu.html.haml'))
  end

  def game_view
    Rack::Response.new(render('game.html.haml'))
  end

  def win_view
    Rack::Response.new(render('win.html.haml'))
  end

  def lose_view
    Rack::Response.new(render('lose.html.haml'))
  end

  def statistics_view
    Rack::Response.new(render('statistics.html.haml'))
  end

  def not_found_view
    Rack::Response.new(render('not_found.html.haml'))
  end

  def rules_view
    Rack::Response.new(render('rules.html.haml'))
  end

  def render(template)
    path = File.expand_path("./../../views/#{template}", __FILE__)
    Haml::Engine.new(File.read(path)).render(binding)
  end
end
