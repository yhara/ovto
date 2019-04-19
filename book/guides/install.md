# Install

## Use Ovto with static files

```
$ gem i ovto
$ ovto new myapp --static
```

## Use Ovto with Sinatra

```
$ gem i ovto
$ ovto new myapp --sinatra
```

## Install Ovto into Rails apps

Edit `Gemfile`

```rb
gem 'opal-rails'
gem 'ovto'
```

Run `bundle install`

Remove `app/assets/javascripts/application.js`

Create `app/assets/javascripts/application.js.rb`

```rb
require 'opal'
require 'rails-ujs'
require 'activestorage'
require 'turbolinks'
require_tree '.'
```

Create `app/assets/javascripts/foo.js.rb` (file name is arbitrary)

```rb
require 'ovto'

class Foo < Ovto::App
  class State < Ovto::State
  end

  class Actions < Ovto::Actions
  end

  class MainComponent < Ovto::Component
    def render(state:)
      o 'h1', "HELLO"
    end
  end
end

Foo.run(id: 'foo-app')
```

Edit `app/views/<some controller/<some view>.html.erb`

```
<div id='foo-app'></div>
<%= opal_tag do %>
  Foo.run(id: 'ovto-app')
<% end %>
```

This should render `HELLO` in the browser.

You also need to edit config/environments/production.rb like this before deploy it to production.

```rb
    #config.assets.js_compressor = :uglifier
    config.assets.js_compressor = Uglifier.new(harmony: true)
```
