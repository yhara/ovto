require 'set'

module Ovto
  # Set of WiredActions (One for the app, zero or more for middlewares)
  class WiredActionSet
    # Special key for @hash
    I_AM_APP_NOT_A_MIDDLEWARE = ''
    THE_MIDDLEWARE_ITSELF = ''

    # For testing
    def self.dummy()
      new(nil, nil, [], [], nil)
    end

    def initialize(app, actions, middleware_path, middlewares, runtime)
      @app = app
      @hash = {}
      @hash[THE_MIDDLEWARE_ITSELF] = WiredActions.new(actions, app, runtime, self)
      middlewares.each do |m|
        mw_path = middleware_path + [m.name]
        mw_actions = m.const_get('Actions').new(mw_path)
        mw_wired_action_set = WiredActionSet.new(app, mw_actions, mw_path, m.middlewares, runtime)
        @hash[m.name] = mw_wired_action_set
        mw_actions.wired_actions = mw_wired_action_set[THE_MIDDLEWARE_ITSELF]
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
