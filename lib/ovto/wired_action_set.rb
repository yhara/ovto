require 'set'

module Ovto
  # Set of WiredActions (One for the app, zero or more for middlewares)
  class WiredActionSet
    # Special key for @hash
    I_AM_APP_NOT_A_MIDDLEWARE = ''

    # For testing
    def self.dummy()
      new(nil, nil, [], nil)
    end

    def initialize(app, app_actions, middlewares, runtime)
      @app = app
      @hash = {}
      @hash[I_AM_APP_NOT_A_MIDDLEWARE] = WiredActions.new(app_actions, app, runtime, self)
      middlewares.each do |m|
        mw_actions = m.const_get('Actions').new
        mw_wired_actions = WiredActions.new(mw_actions, app, runtime, self)
        @hash[m.name] = mw_wired_actions
        mw_actions.wired_actions = mw_wired_actions
      end
      @middleware_names = middlewares.map(&:name).to_set
    end
    attr_reader :app, :middleware_names

    # Return the WiredActions of the app
    def app_wired_actions
      @hash[I_AM_APP_NOT_A_MIDDLEWARE]
    end

    # Return the WiredActions of a middleware
    def [](name)
      @hash.fetch(name)
    end
  end
end
