require_relative './dependency'

use Rack::Reloader
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'
use Rack::Static, urls: ['/css', '/images', '/js'], root: 'public'

run Racker
