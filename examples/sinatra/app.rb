require 'sinatra/base'
require 'sinatra/reloader'
require 'opal'

class SinatraApp < Sinatra::Base
  configure(:development) do
    register Sinatra::Reloader
    also_reload "#{__dir__}/**/*.rb"
  end

  get '/' do
    @js_tag = $GENERATE_JAVASCRIPT_INCLUDE_TAG.call # Defined in config.ru
    erb :index  # Render views/index.erb
  end
end
