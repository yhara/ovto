# Ovto::Actions

Actions are the only way to change the state. Actions must be defined as methods of
the `Actions` class. Here is some more conventions:

- You must use keyword arguments
- You must provide `state:` keyword to receive the app state
- You must return state updates as a Hash. It will be merged into the app state.

Example:

```rb
require 'opal'
require 'ovto'

class MyApp < Ovto::App
  class State < Ovto::State
    item :count, 0
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
```

## Calling actions

Actions can be called from components via `actions` method. This is an instance of
`Ovto::WiredActions` and has methods of the same name as your `Actions` class.

      o 'button', onclick: ->{ actions.increment(by: 1) }

Arguments are almost the same as the original but you don't need to provide `state`;
it is automatically passed by `Ovto::WiredActions` class. It also updates the app
state with the return value of the action, and schedules rendering the view.

## Skipping state update

An action may return `nil` when no app state changes are needed.

Promises are also special values which does not cause state changes (see the next section).

## Async actions

When calling server apis, you cannot tell how the app state will change until the server responds.
In such cases, you can call another action via `actions` to tell Ovto to reflect the api result to the app state.

Example:

```rb
  class Actions < Ovto::Actions
    def fetch_tasks(state:)
      Ovto.fetch('/tasks.json').then {|tasks_json|
        actions.receive_tasks(tasks: tasks_json)
      }.fail {|e|
        console.log("failed:", e)
      }
    end

    def receive_tasks(state:, tasks_json:)
      tasks = tasks_json.map{|item| Task.new(**item)}
      return {tasks: tasks}
    end
  end
```
