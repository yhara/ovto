module Ovto
  # Base class for ovto actions.
  class Actions
    # WiredActions must be set after initialization
    # (this cannot be an argument of #initialize because Actions and
    # WiredActions have references to each other)
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
