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

  class View < Ovto::Component
    def render(state)
      o 'input', {
        type: 'button',
        value: 'Hello',
        style: `{background: #{COLORS[state.color_idx]}}`,
        onclick: ->{ actions.update_color },
      }
    end
  end
end

MyApp.run(id: 'ovto-view')
