# Ovto::Middleware

When you are making a big app with Ovto, you may want to extract
certain parts which are independent from the app. Ovto::Middleware is
for such cases.

- A middleware has its own namespace of state and actions
  - that is, you don't need to add prefixes to the names of states and actions of a middleware.

## Example

```rb
# 1. Middleware name must be valid as a method name in Ruby
class MyMiddleware < Ovto::Middleware("my_middleware")
  def setup
    # Called on app startup
  end

  # 2. Make a subclass of MyMiddleware's State
  class State < MyMiddleware::State
    item :count, default: 0
  end

  # 3. Make a subclass of MyMiddleware's Actions
  class Actions < MyMiddleware::Actions
    def increment(by:)
      return {count: state.count + by}
    end
  end

  # 4. Make a subclass of MyMiddleware's Component
  class SomeComponent < MyMiddleware::Component
    def render
      o 'span', state.count
      o 'button', onclick: ->{ actions.increment(by: 1) }
    end
  end
end

class MyApp < Ovto::App
  # 5. Declare middlewares to use
  use MyMiddleware

  class State < Ovto::State; end
  class Actions < Ovto::Actions; end

  class MainComponent < Ovto::Component
    def render
      o 'div.counter' do
        o MyMiddleware::SomeComponent
      end
    end
  end
```

## Advanced

### Getting middlware state from app

```rb
class MyApp < Ovto::App
  def MainComponent < Ovto::Component
    def render
      o 'span', state._middlewares.middleware1.some_state
    end
  end
```

### Calling middlware action from app

```rb
class MyApp < Ovto::App
  # From actions
  def Actions < Ovto::Actions
    def some_action
      actions.middleware1.some_action()
    end
  end

  # From component
  def MainComponent < Ovto::Component
    def render
      o 'button', onclick: ->{ actions.middleware1.some_action() }
    end
  end
```

### Using a middleware from another middleware

```rb
class Middleware1 < Ovto::Middleware("middleware1")
  use Middleware2
```
