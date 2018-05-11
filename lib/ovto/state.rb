module Ovto
  class State
    class MissingValue < StandardError; end

    # (internal) initialize subclass
    def self.inherited(subclass)
      subclass.instance_variable_set('@item_specs', [])
    end

    # Declare state item
    def self.item(name, options={})
      @item_specs << [name, options]
      # Define accessor
      define_method(name){ @values[name] }
    end

    # Return list of item specs
    def self.item_specs
      @item_specs
    end

    def initialize(hash = {})
      @values = self.class.item_specs.map{|name, options|
        if !hash.key?(name) && !options.key?(:default)
          raise MissingValue, ":#{name} is mandatory for #{self.class.name}.new"
        end
        # Note that `hash[key]` may be false or nil
        value = hash.key?(name) ? hash[name] : options[:default]
        [name, value]
      }.to_h
    end

    # Create new state object from `self` and `hash`
    def merge(hash)
      self.class.new(@values.merge(hash))
    end

    # Return the value corresponds to `key`
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
