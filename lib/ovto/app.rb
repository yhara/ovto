module Ovto
  class App
    def initialize
      @state = self.class.const_get('State').new
    end
    attr_reader :state

    # Internal use only
    def _set_state(new_state)
      @state = new_state
    end

    def run(id: nil)
      runtime = Ovto::Runtime.new(self)
      wired_actions = WiredActions.new(self.class.const_get('Actions').new, self, runtime)
      view = self.class.const_get('View').new(wired_actions)
      container = id && `document.getElementById(id)`
      runtime.run(view, container)
    end
  end
end
