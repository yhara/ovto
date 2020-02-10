module Ovto
  class App
    # List of installed middleware classes
    def self.middlewares
      @middlewares ||= []
    end

    # Create an App and start it
    def self.run(*args)
      new.run(*args)
    end

    # Install a middleware
    def self.use(middleware_class)
      self.middlewares.push(middleware_class)
    end

    def initialize
      app_state_class = self.class.const_get('State')
      # Inject middleware states
      app_state_class.item :_middlewares, default_proc: ->{
        Ovto::Middleware.create_middleware_states_class(self.class.middlewares).new
      }
      @state = app_state_class.new
      @wired_action_set = nil
      @main_component = nil
    end
    attr_reader :state

    # An instance of YourApp::MainComponent (mainly for testing)
    attr_reader :main_component

    def actions
      @wired_action_set.app_wired_actions
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
      @wired_action_set = WiredActionSet.new(self, actions, self.class.middlewares, runtime)
      actions.wired_actions = @wired_action_set.app_wired_actions
      @main_component = create_view(@wired_action_set)
      if id
        %x{
          document.addEventListener('DOMContentLoaded', function(){
            var container = document.getElementById(id);
            if (!container) {
              throw "Ovto::App#run: tag with id='" + id + "' was not found";
            }
            #{start_application(runtime, `container`)}
          });
        }
      else
        start_application(runtime, nil)
      end
    end

    # Instantiate MyApp::MainComponent
    def create_view(wired_action_set)
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
      return main_component_class.new(wired_action_set)
    end

    def start_application(runtime, container)
      runtime.run(@main_component, container)
      setup
    end
  end
end
