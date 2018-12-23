# Getting Started

This is a tutorial of making an Ovto app. We create a static app (.html + .js) here,
but you can embed Ovto apps into a Rails or Sinatra app (See `./example/*`).

This is the final Ruby code.

```
require 'ovto'

class MyApp < Ovto::App
  class State < Ovto::State
    item :celsius, default: 0

    def fahrenheit
      (celsius * 9 / 5.0) + 32
    end
  end

  class Actions < Ovto::Actions
    def set_celsius(state:, value:)
      return {celsius: value}
    end

    def set_fahrenheit(state:, value:)
      new_celsius = (value - 32) * 5 / 9.0
      return {celsius: new_celsius}
    end
  end

  class MainComponent < Ovto::Component
    def render(state:)
      o 'div' do
        o 'span', 'Celcius:'
        o 'input', {
          type: 'text',
          onchange: ->(e){ actions.set_celsius(value: e.target.value.to_i) },
          value: state.celsius
        }
        o 'span', 'Fahrenheit:'
        o 'input', {
          type: 'text',
          onchange: ->(e){ actions.set_fahrenheit(value: e.target.value.to_i) },
          value: state.fahrenheit
        }
      end
    end
  end
end

MyApp.run(id: 'ovto')
```

Let's take a look step-by-step.

## Prerequisites

- Ruby
- Bundler (`gem install bundler`)

## Setup

Make a Gemfile:

```
source "https://rubygems.org"
gem "ovto", github: 'yhara/ovto'  # Use git master because ovto gem is not released yet
gem 'rake'
```

Run `bundle install`.

## HTML

Make an index.html:

```html
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <script type='text/javascript' src='app.js'></script>
  </head>
  <body>
    <div id='ovto'></div>
    <div id='ovto-debug'></div>
  </body>
</html>
```

## Write code

app.rb:

```rb
require 'ovto'

class MyApp < Ovto::App
  class State < Ovto::State
  end

  class Actions < Ovto::Actions
  end

  class MainComponent < Ovto::Component
    def render(state:)   # Don't miss the `:`. This is not a typo but
      o 'div' do         # a "mandatory keyword argument".
        o 'h1', "HELLO"  # All of the Ovto methods take keyword arguments.
      end
    end
  end
end

MyApp.run(id: 'ovto')
```

- The name `MyApp` is arbitrary.
- The id `ovto` corresponds to the `div` tag in `index.html`.

## Compile

Generate app.js from app.rb.

```
$ bundle exec opal -c -g ovto app.rb > app.js
```

(Compile will fail if there is a syntax error in your `app.rb`.)

Now you can run your app by opening `index.html` in your browser.

## Trouble shooting

If you see HELLO, the setup is done. Otherwise, check the developer console
and you should see some error messages there.

For example if you misspelled `class State` to `class Stat`, you will see:

```
app.js:5022 Uncaught $NameError {name: "State", message: "uninitialized constant MyApp::State", stack: "State: uninitialized constant MyApp::State"}
```

because an Ovto app must have a `State` class in its namespace.

## (Tips: auto-compile)

If you get tired to run `bundle exec opal` manually, try `ifchanged` gem:

1. Add `gem "ifchanged"` to Gemfile
1. `bundle install`
1. `bundle exec ifchanged ./app.rb --do 'bundle exec opal -c -g ovto app.rb > app.js'`

Now you just edit and save `app.rb` and it runs `opal -c` for you.

## Add some state

In this tutorial, we make an app that convers Celsius and Fahrenheit degrees to
each other. First, add an item to `MyApp::State`.

```rb
  class State < Ovto::State
    item :celsius, default: 0
  end
```

Now an item `celsius` is added to the global app state. Its value is `0` when
the app starts. You can read this value by `state.celsius`. Let's display the
value with `MyApp::MainComponent`.

```rb
  class MainComponent < Ovto::Component
    def render(state:)
      o 'div' do
        o 'span', 'Celcius:'
        o 'input', type: 'text', value: state.celsius
      end
    end
  end
```

Now you should see `Celsius: [0      ]` in the browser.

## Add a method to State

Next, we want to know what degree is it in Fahrenheit. Let's add a method to
convert.

```rb
  class State < Ovto::State
    item :celsius, default: 0

    def fahrenheit
      (celsius * 9 / 5.0) + 32
    end
  end
```

Now you can know the value by `state.fahrenheit`. Update `MainComponent` to show the value too.

```
  class MainComponent < Ovto::Component
    def render(state:)
      o 'div' do
        o 'span', 'Celcius:'
        o 'input', type: 'text', value: state.celsius
        o 'span', 'Fahrenheit:'
        o 'input', type: 'text', value: state.fahrenheit
      end
    end
  end
```

## Add an action

Now we know 0 degrees Celsius is 32 degrees Fahrenheit. But how about 10 degrees or
100 degrees Celsius? Let's update the app to we can specify a Celsius value.

You may think that you can change the value with `state.celsius = 100`, but this is
prohibited. In Ovto, you can only modify app state with Actions.

Our first action looks like this. An action is a method defined in `MyApp::Actions`.
It takes an old state (and its own parameters) and returns a Hash that describes
the updates to the state. This return value is `merge`d into the global app state.

```rb
  class Actions < Ovto::Actions
    def set_celsius(state:, value:)
      return {celsius: value}
    end
  end
```

This action can be called by `actions.set_celsius` from MainComponent. Replace the
first input tag with this:

```rb
        o 'input', {
          type: 'text',
          onchange: ->(e){ actions.set_celsius(value: e.target.value.to_i) },
          value: state.celsius
        }
```

`onchange:` is a special attribute that takes an event handler as its value.
The argument `e` is an instance of `Opal::Native` and wraps the event object of
JavaScript. In this case you can get the input string by `e.target.value`.

Now reload your browser and input `100` to the left input box. Next, press Tab key
(or click somewhere in the page) to commit the value. Then you should see `212`
in the right input box. 100 degrees Celsius is 212 degrees Fahrenheit!

## What has happend

In case you are curious, here is what happens when you give 100 to the input box.

1. JavaScript's `onchange` event is executed.
1. Ovto calls the event handler.
1. It calls `actions.set_celsius`. `actions` is an instance of `Ovto::WiredActions`.
  It is a proxy to the `MyApp::Actions`. It has the same methods as those in
  `MyApp::Actions` but does some more:
  - It passes `state` to the user-defined action.
  - It merges the result to the global app state.
  - It schedules re-rendering the view to represent the new state.

## Reverse conversion

It is easy to update the app to support Fahrenheit-to-Celsius conversion.
The second input should be updated to:

```rb
        o 'input', {
          type: 'text',
          onchange: ->(e){ actions.set_fahrenheit(value: e.target.value.to_i) },
          value: state.fahrenheit
        }
```

Then add an action `set_fahrenheit` to `MyApp::Actions`. This action convers the
Fahrenheit degree into Celsius and set it to the global state.

```rb
    def set_fahrenheit(state:, value:)
      new_celsius = (value - 32) * 5 / 9.0
      return {celsius: new_celsius}
    end
```

Now your app should react to the change of the Fahrenheit value too. 
