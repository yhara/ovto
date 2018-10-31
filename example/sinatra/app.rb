require 'sinatra/base'
require 'sinatra/reloader'
require 'opal'

class SinatraApp < Sinatra::Base
  # Proc to generate javascript include tag (see config.ru)
  set :generate_javascript_include_tag, nil

  configure(:development) do
    register Sinatra::Reloader
    also_reload "#{__dir__}/**/*.rb"
  end

  get '/' do
    @js_tag = options.generate_javascript_include_tag
    erb :index  # Render views/index.erb
  end
end
