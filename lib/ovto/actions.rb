module Ovto
  # Base class for ovto actions.
  class Actions
    attr_writer :wired_actions

    def actions
      @wired_actions
    end
  end
end
