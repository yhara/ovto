module Ovto
  class WiredActions
    def initialize(actions, app, runtime)
      @actions, @app, @runtime = actions, app, runtime
    end

    def method_missing(name, *args)
      invoke_action(name, *args)
    end

    def respond_to?(name)
      @actions.respond_to?(name)
    end

    private

    # Call action and schedule rendering
    def invoke_action(name, *args)
      new_state = @actions.__send__(name, @app.state, *args)
      @app._set_state(new_state)
      @runtime.scheduleRender
      return new_state
    end
  end
end
