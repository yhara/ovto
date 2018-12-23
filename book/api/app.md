# Ovto::App

First of all, you need to define a subclass of `Ovto::App` and define `class State`,
`class Actions` and `class MainComponent` in it.

## Example

This is a smallest Ovto app.

```rb
require 'opal'
require 'ovto'

class MyApp < Ovto::App
  class State < Ovto::State
  end

  class Actions < Ovto::Actions
  end

  class MainComponent < Ovto::Component
    def render(state:)
      o 'input', type: 'button', value: 'Hello'
    end
  end
end

MyApp.run(id: 'ovto')
```

It renders a button and does nothing else. Let's have some fun:

```rb
require 'opal'
require 'ovto'

class MyApp < Ovto::App
  COLORS = ["red", "blue", "green"]

  class State < Ovto::State
    item :color_idx, default: 0
  end

  class Actions < Ovto::Actions
    def update_color(state:)
      new_idx = (state.color_idx + 1) % COLORS.length
      return {color_idx: new_idx}
    end
  end

  class MainComponent < Ovto::Component
    def render(state:)
      o 'input', {
        type: 'button',
        value: 'Hello',
        style: {background: COLORS[state.color_idx]},
        onclick: ->{ actions.update_color },
      }
    end
  end
end

MyApp.run(id: 'ovto')
```

Here we added `color_idx` to app state and `update_color` action to change it.
The button is updated to have the color indicated by `color_idx` and
now has `onclick` event handler which executes the action.

## Calling actions on startup

To invoke certain actions on app startup, define `MyApp#setup` and use `MyApp#actions`.

Example:

```rb
class MyApp < Ovto::App
  def setup
    actions.fetch_data()
  end

  ...
end

MyApp.run(id: 'ovto')
```
