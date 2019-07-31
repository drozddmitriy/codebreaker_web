require 'rack/test'
require 'simplecov'

SimpleCov.start do
  minimum_coverage 90
end

require './dependency'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
