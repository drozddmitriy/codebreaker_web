module RenderModule
  def menu_view
    Rack::Response.new(render('menu.html.erb'))
  end

  def game_view
    Rack::Response.new(render('game.html.erb'))
  end

  def win_view
    Rack::Response.new(render('win.html.erb'))
  end

  def lose_view
    Rack::Response.new(render('lose.html.erb'))
  end

  def statistics_view
    Rack::Response.new(render('statistics.html.erb'))
  end

  def error404_view
    Rack::Response.new(render('error_404.html.erb'))
  end

  def rules_view
    Rack::Response.new(render('rules.html.erb'))
  end

  def render(template)
    path = File.expand_path("./../../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end
end
