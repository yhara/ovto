require 'native'
require 'promise'

module Ovto
  class WiredActions
    # Create a WiredActions
    #
    # - actions: Ovto::Actions
    # - app: Ovto::App
    # - runtime: Ovto::Runtime (to call scheduleRender after state change)
    # - parent: WiredActionSet
    def initialize(actions, app, runtime, parent)
      @actions, @app, @runtime, @parent = actions, app, runtime, parent
    end

    def method_missing(name, args_hash={})
      raise NoMethodError, "undefined method `#{name}' on #{self}" unless respond_to?(name)
      if @actions.respond_to?(name)
        Ovto.log_error {
          Ovto.debug_trace_log("invoke action \"#{name}\" on #{@actions.class}")
          invoke_action(name, args_hash)
        }
      else
        @parent[name][WiredActionSet::THE_MIDDLEWARE_ITSELF]  # WiredActions of a middleware named `name`
      end
    end

    def respond_to?(name)
      @actions.respond_to?(name) || @parent.middleware_names.include?(name)
    end

    # internal
    def _app
      @app
    end

    private

    # Call action and schedule rendering
    def invoke_action(name, args_hash)
      state_diff = Ovto.send_args_with_state(@actions, name, args_hash, current_state)
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
      @actions.state
    end

    def update_state(new_item)
      new_app_state = _new_app_state(@actions.middleware_path, @app.state, new_item)
      @app._set_state(new_app_state)
    end

    def _new_app_state(middleware_path, old_state, new_item)
      if middleware_path.empty?
        return new_item
      else
        first, *rest = *middleware_path
        orig_state = old_state._middlewares.__send__(first)
        return old_state.merge(
          _middlewares: old_state._middlewares.merge(
            first => _new_app_state(rest, orig_state, new_item)
          )
        )
      end
    end
  end
end
