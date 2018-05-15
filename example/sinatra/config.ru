require 'opal/sprockets'
require_relative './sinatra/app.rb'

Opal.use_gem 'ovto'
opal = Opal::Sprockets::Server.new {|s|
  s.append_path './ovto/'
  s.main = 'app'
}

sprockets   = opal.sprockets
prefix      = '/assets'
maps_prefix = '/__OPAL_SOURCE_MAPS__'
maps_app    = Opal::SourceMapServer.new(sprockets, maps_prefix)

# Monkeypatch sourcemap header support into sprockets
::Opal::Sprockets::SourceMapHeaderPatch.inject!(maps_prefix)

map maps_prefix do
  run maps_app
end

map prefix do
  run sprockets
end

run Sinatra.new(SinatraApp){
  set :generate_javascript_include_tag, proc{
    ::Opal::Sprockets.javascript_include_tag('app', sprockets: sprockets, prefix: prefix, debug: true)
  }
}
