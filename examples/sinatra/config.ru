require 'opal/sprockets'
require_relative './app.rb'

Opal.use_gem 'ovto'
opal_server = Opal::Sprockets::Server.new {|s|
  s.append_path './ovto/'
  s.main = 'app'
}

sprockets   = opal_server.sprockets
prefix      = '/assets'

map prefix do
  run sprockets
end

$GENERATE_JAVASCRIPT_INCLUDE_TAG = ->{
  ::Opal::Sprockets.javascript_include_tag('app', sprockets: sprockets, prefix: prefix, debug: true)
}

run SinatraApp
