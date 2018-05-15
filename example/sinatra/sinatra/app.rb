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
    <<-EOD
      <!doctype html>
      <html>
        <head>
          <meta charset="utf-8">
          #{options.generate_javascript_include_tag}
        </head>
        <body>
          <h1>Ovto + Sinatra</h1>
          <div id='ovto-view'></div>
          <div id='ovto-debug'></div>
        </body>
      </html>
    EOD
  end
end
