module Ovto
  class PureComponent < Component
    class StateIsNotAvailable < StandardError; end

    def initialize(*args)
      super
      @prev_props = nil
      @cache = nil
    end

    def do_render(args, state)
      return @cache if args == @prev_props

      @prev_props = args
      @cache = super
    end

    def state
      raise StateIsNotAvailable, "Cannot use state in PureComponent"
    end
  end
end
