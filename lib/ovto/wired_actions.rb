require 'native'
require 'promise'

module Ovto
  class WiredActions
    # Create a WiredActions
    #
    # - runtime: Ovto::Runtime (to call scheduleRender after state change)
    def initialize(actions, app, runtime)
      @actions, @app, @runtime = actions, app, runtime
    end

    def method_missing(name, args_hash={})
      raise NoMethodError, "undefined method `#{name}' on #{self}" unless respond_to?(name)
      Ovto.log_error {
        invoke_action(name, args_hash)
      }
    end

    def respond_to?(name)
      @actions.respond_to?(name)
    end

    # internal
    def _app
      @app
    end

    private

    # Call action and schedule rendering
    def invoke_action(name, args_hash)
      kwargs = {state: current_state}.merge(args_hash)
      state_diff = @actions.__send__(name, **kwargs)
      return if state_diff.nil? ||
                state_diff.is_a?(Promise) || `!!state_diff.then` ||
                # eg.
                #   def action1(state:)
                #     actions.action2 if some_condition  #=> MyApp::State or nil
                #   end
                state_diff.is_a?(Ovto::State)

      if native?(state_diff)
        raise "action `#{name}' returned js object: #{`name.toString()`}"
      end
      unless state_diff.is_a?(Hash)
        raise "action `#{name}' must return hash but got #{state_diff.inspect}"
      end
      new_state = current_state.merge(state_diff)
      if new_state != current_state
        @runtime.scheduleRender
        update_state(new_state)
      end
      return new_state
    end

    def middleware_name
      @actions.middleware_name
    end

    def current_state
      if middleware_name == WiredActionSet::I_AM_APP_NOT_A_MIDDLEWARE
        @app.state
      else
        @app.state._middlewares.__send__(middleware_name)
      end
    end

    def update_state(new_state)
      if middleware_name == WiredActionSet::I_AM_APP_NOT_A_MIDDLEWARE
        new_app_state = new_state
      else
        middleware_states = @app.state._middlewares
        new_app_state = @app.state.merge(
          _middlewares: middleware_states.merge(middleware_name => new_state)
        )
      end
      @app._set_state(new_app_state)
    end
  end
end
