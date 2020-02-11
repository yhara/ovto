module Ovto
  VALID_NAME_REXP = /\A[a-zA-Z0-9_]+\z/
  # Create an ancestor of middleware class
  # Example:
  #     class MiddlewareExample < Ovto::Middleware("middleware_example")
  def self.Middleware(name)
    unless VALID_NAME_REXP =~ name
      raise "invalid middleware name: #{name}"
    end
    return Class.new(Ovto::Middleware::Base){
      const_set(:OVTO_MIDDLEWARE_NAME, name)
      const_set(:State, Ovto::State)
      const_set(:Actions, Class.new(Ovto::Middleware::Actions))
      const_get(:Actions).const_set(:OVTO_MIDDLEWARE_NAME, name)
      const_set(:Component, Class.new(Ovto::Middleware::Component))
      const_get(:Component).const_set(:OVTO_MIDDLEWARE_NAME, name)
    }
  end

  module Middleware
    # (internal) Create a subclass of Ovto::State that handles
    # states of `middlewares`
    # Called from App#initialize
    def self.create_middleware_states_class(middlewares)
      return Class.new(Ovto::State){
        middlewares.each do |m|
          item m.name, default: m.const_get('State').new
        end
      }
    end
  end

  # Base class of a middleware class
  # Note: this is not the direct superclass of a middleware.
  # `SomeMiddleware < (anonymous class) < Middleware::Base`
  class Middleware::Base
    # Middleware name (set by Ovto.Middleware)
    def self.name
      const_get(:OVTO_MIDDLEWARE_NAME)
    end
  end

  class Middleware::Actions < Ovto::Actions
    # The name of the middleware this Actions belongs to
    def middleware_name
      self.class::OVTO_MIDDLEWARE_NAME
    end
  end

  # Base class of middleware component
  # Basically the same as Ovto::Component but `actions` is wired to
  # middleware actions.
  class Middleware::Component < Ovto::Component
    def self.middleware_name
      self::OVTO_MIDDLEWARE_NAME
    end

    # The name of the middleware this component belongs to
    def middleware_name
      self.class::OVTO_MIDDLEWARE_NAME
    end

    def state
      app_state = super
      return app_state._middlewares.__send__(middleware_name)
    end
  end
end
