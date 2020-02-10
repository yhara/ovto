module Ovto
  # Base class for ovto actions.
  class Actions
    attr_writer :wired_actions

    def actions
      @wired_actions
    end

    def state
      @wired_actions._app.state
    end

    def middleware_name
      WiredActionSet::I_AM_APP_NOT_A_MIDDLEWARE
    end
  end
end
