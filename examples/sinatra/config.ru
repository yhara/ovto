require 'opal/sprockets'
require_relative './app.rb'

Opal.use_gem 'ovto'
opal = Opal::Sprockets::Server.new {|s|
  s.append_path './ovto/'
  s.main = 'app'
}

sprockets   = opal.sprockets
prefix      = '/assets'

map prefix do
  run sprockets
end

run Sinatra.new(SinatraApp){
  set :generate_javascript_include_tag, proc{
    ::Opal::Sprockets.javascript_include_tag('app', sprockets: sprockets, prefix: prefix, debug: true)
  }
}
