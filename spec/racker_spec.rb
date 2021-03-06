require 'spec_helper'

RSpec.describe Racker do
  DIFFICULTIES = Codebreaker::Game::DIFFICULTIES
  let(:path) { 'data_test.yml' }
  let(:app) { Rack::Builder.parse_file('config.ru').first }
  let(:game) { Codebreaker::Game.new }

  describe '#statuses' do
    context 'when root path' do
      before { get '/' }

      it { expect(last_response.status).to eq 200 }

      it { expect(last_response.body).to include I18n.t(:start_game) }
    end

    context 'when unknown routes' do
      before { get '/unknown' }

      it { expect(last_response.status).to eq 200 }
      it 'returns status not found' do
        expect(last_response.body).to include I18n.t(:page_not_found)
      end
    end

    context 'when rules path' do
      before { get '/rules' }

      it { expect(last_response.status).to eq 200 }

      it { expect(last_response.body).to include I18n.t(:game_rules_1) }
    end

    context 'when statistics path' do
      let(:path) { Codebreaker::DatabaseModule::FILE_NAME }
      before do
        File.new(path, 'w+')
        get '/statistics'
      end

      after { File.delete(path) }

      it { expect(last_response.status).to eq 200 }
      it { expect(last_response.body).to include I18n.t(:top_players) }
    end
  end

  describe '#hint' do
    before do
      game.hints_total = 2
      game.hints_used = 1
      game.set_code
      env 'rack.session', game: game, show_hint: false
      post '/hint'
    end

    it 'adds value to session hint' do
      expect(last_request.session[:show_hint]).not_to be_empty
    end
  end

  describe '#attempt' do
    before do
      game.set_code
      game.difficulty_player(I18n.t(:hell, scope: [:difficulty]), DIFFICULTIES[:hell][:attempts])
      env 'rack.session', game: game, show_hint: false
      post '/attempt', number: '1234'
    end

    it 'check response with attempt' do
      expect(last_request.session[:attempt]).to be_a String
    end
  end

  describe '#game' do
    before do
      post '/game', player_name: 'test', level: I18n.t(:hell, scope: [:difficulty])
    end

    context 'when game page response' do
      it { expect(last_response.status).to eq 200 }

      it 'contains player_name' do
        expect(last_response.body).to include I18n.t(:hello_msg, name: last_request.session[:game].player)
      end
    end
  end

  describe '#win' do
    context 'when win path' do
      before do
        File.new(path, 'w+')
        stub_const('Racker::FILE_NAME', path)
        game.player = 'test'
        game.difficulty_player(I18n.t(:hell, scope: [:difficulty]), DIFFICULTIES[:hell][:attempts])
        env 'rack.session', game: game, win: true
        get '/win'
      end

      after do
        File.delete(path)
      end

      it { expect(last_response.status).to eq 200 }

      it 'show win page' do
        expect(last_response.body).to include I18n.t(:congratulations, name: game.player)
      end
    end
  end

  describe '#redirect to game' do
    before do
      game.player = 'test'
      game.attempts = 5
      game.try = 2
      game.difficulty_player(I18n.t(:hell, scope: [:difficulty]), DIFFICULTIES[:hell][:attempts])
      env 'rack.session', game: game, attempt_code: '1234'
      get '/win'
    end

    it { expect(last_response.status).to eq 302 }

    it 'follow redirect' do
      follow_redirect!
      expect(last_response.body).to include I18n.t(:hello_msg, name: last_request.session[:game].player)
    end
  end

  describe '#lose' do
    context 'when lose path' do
      before do
        game.player = 'test'
        game.attempts = 5
        game.try = 5
        env 'rack.session', game: game
        get '/lose'
      end

      it { expect(last_response.status).to eq 200 }

      it 'show lose page' do
        expect(last_response.body).to include I18n.t(:oops, name: game.player)
      end
    end

    context 'redirect to game' do
      before do
        game.player = 'test'
        game.attempts = 5
        game.try = 2
        game.difficulty_player(I18n.t(:hell, scope: [:difficulty]), DIFFICULTIES[:hell][:attempts])
        env 'rack.session', game: game, attempt_code: '1234'
        get '/lose'
      end

      it { expect(last_response.status).to eq 302 }

      it 'follow redirect' do
        follow_redirect!
        expect(last_response.body).to include I18n.t(:hello_msg, name: last_request.session[:game].player)
      end
    end
  end
end
