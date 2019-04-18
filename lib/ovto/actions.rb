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
  end
end
