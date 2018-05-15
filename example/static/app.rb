require 'opal'
require 'ovto'

class MyApp < Ovto::App
  class State < Ovto::State
    item :count, default: 0
  end

  class Actions < Ovto::Actions
    def increment(state:, by:)
      return {count: state.count + by}
    end
  end

  class View < Ovto::Component
    def render(state:)
      o 'span', state.count
      o 'button', onclick: ->{ actions.increment(by: 1) }
    end
  end
end

MyApp.run(id: 'ovto-view')
