module Ovto
  class Component
    def initialize(wired_actions)
      @wired_actions = wired_actions
    end

    def render
      ''
    end

    private

    def actions
      @wired_actions
    end

    def o(*args, &block)
      builder = VDomBuilder.new(@wired_actions)
      builder.o(*args, &block)
      return builder.result.first
    end

    def text(s)
      s
    end
  end
end
