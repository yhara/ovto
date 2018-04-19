require 'opal/sprockets'

Opal.use_gem 'ovto'

run Opal::Sprockets::Server.new{|s|
  # Let javascript_include_tag to serve compiled version of opal/dxopal.rb
  s.append_path 'app'
  s.main = 'demo'
  s.index_path = 'index.html.erb'
  # Serve static files
  #s.public_root = __dir__
  # Just serve static ./index.html
  #s.use_index = false
}
