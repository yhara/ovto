module Ovto
  class App
    # Create an App and start it
    def self.run(*args)
      new.run(*args)
    end

    def initialize
      @state = self.class.const_get('State').new
      @wired_actions = nil
    end
    attr_reader :state

    def actions
      @wired_actions
    end

    # Internal use only
    def _set_state(new_state)
      @state = new_state
    end

    # Start this app
    def run(*args)
      Ovto.log_error{ _run(*args) }
    end

    # Called when this app is started
    def setup
      # override this if needed
    end

    private

    # Setup runtime and wired_actions
    def _run(id: nil)
      runtime = Ovto::Runtime.new(self)
      actions = self.class.const_get('Actions').new
      @wired_actions = WiredActions.new(actions, self, runtime)
      actions.wired_actions = @wired_actions
      view = create_view
      if id
        %x{
          document.addEventListener('DOMContentLoaded', function(){
            var container = document.getElementById(id);
            if (!container) {
              throw "Ovto::App#run: tag with id='" + id + "' was not found";
            }
            #{start_application(runtime, view, `container`)}
          });
        }
      else
        start_application(runtime, view, nil)
      end
    end

    # Instantiate MyApp::MainComponent
    def create_view
      begin
        main_component_class = self.class.const_get('MainComponent')
      rescue NameError => orig_ex
        begin
          self.class.const_get('View')
        rescue NameError
          raise orig_ex
        else
          raise "Since Ovto 0.3.0, View is renamed to MainComponent. Please rename "+
                "#{self.class}::View to #{self.class}::MainComponent"
        end
      end
      return main_component_class.new(@wired_actions)
    end

    def start_application(runtime, view, container)
      runtime.run(view, container)
      setup
    end
  end
end
