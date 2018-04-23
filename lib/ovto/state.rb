module Ovto
  class State
    def self.item(name, initial_value)
      @item_specs ||= []
      @item_specs << [name, initial_value]
      define_method(name){ @values[name] }
    end

    def self.item_specs
      @item_specs
    end

    def initialize(hash = {})
      @values = self.class.item_specs.to_h.merge(hash)
    end

    def merge(hash)
      self.class.new(@values.merge(hash))
    end

    def [](key)
      @values[key]
    end

    def to_h
      @values
    end

    def inspect
      "#<#{self.class.name}:#{object_id} #{@values.inspect}>"
    end
  end
end
