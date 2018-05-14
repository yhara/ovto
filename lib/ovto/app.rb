module Ovto
  class App
    # Entry point of Ovto apps
    def self.run(*args)
      Ovto.log_error{ new.run(*args) }
    end

    def initialize
      @state = self.class.const_get('State').new
    end
    attr_reader :state

    # Internal use only
    def _set_state(new_state)
      @state = new_state
    end

    # Start this app
    def run(id: nil)
      runtime = Ovto::Runtime.new(self)
      wired_actions = WiredActions.new(self.class.const_get('Actions').new, self, runtime)
      view = self.class.const_get('View').new(wired_actions)
      if id
        %x{
          document.addEventListener('DOMContentLoaded', function(){
            var container = document.getElementById(id);
            if (!container) {
              throw "Ovto::App#run: tag with id='" + id + "' was not found";
            }
            #{runtime.run(view, `container`)}
          });
        }
      else
        runtime.run(view, nil)
      end
    end
  end
end
