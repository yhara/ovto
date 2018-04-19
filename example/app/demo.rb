require 'opal'
require 'ovto'

class TodoApp < Ovto::App
  class State < Ovto::State
    item :todos, []
    item :filter, :all
    item :input, ""
  end

  module Actions
    def add_todo(state)

    end
  end

  class View < Ovto::Component
    def render(state)
      o 'div' do
        o 'h1', {}, 'Todo'
      end
    end
  end
end

Ovto.run(TodoApp)
p 1
