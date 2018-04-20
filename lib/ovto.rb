if RUBY_ENGINE == 'opal'
  require_relative 'ovto/runtime'
  require_relative 'ovto/version'
else
  require 'ovto/version'
  require 'opal'; Opal.append_path("#{__dir__}/..")
end

module Ovto
  # JS-object-safe inspect
  def inspect(obj)
    return obj.inspect if RUBY_ENGINE != "opal"

    if `#{obj}.$object_id`
      obj.inspect
    else
      `JSON.stringify(#{obj}) || "undefined"`
    end
  end

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
      State.new(@values.merge(hash))
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

  class VDomBuilder
    def self.hash_to_js_obj(hash)
      ret = `{}`
      hash.each do |k, v|
        `ret[k] = v`
      end
      ret
    end

    def initialize(wired_actions)
      @wired_actions = wired_actions
      @result = []
    end
    attr_reader :result
    
    def o(tag_name, attributes=nil, content=nil, &block)
      children = render_children(content, block)
      case tag_name
      when Component
        @result << render_component(tag_name, attributes, children)
      when String
        @result << render_tag(tag_name, attributes, children)
      else
        raise TypeError, "tag_name must be a String or Component but got "+
          Ovto.inspect(tag_name)
      end
    end

    def text(s)
      @result << s
    end

    private

    def actions
      @wired_actions
    end

    def render_children(content=nil, block=nil)
      return [] if !content && !block
      raise ArgumentError, "o cannot take both content and block" if content && block
      
      if content
        [content]
      else
        builder = VDomBuilder.new(@wired_actions)
        builder.instance_eval(&block)
        builder.result
      end
    end

    def render_component(comp_class, args, children)
      comp = comp_class.new(@wired_actions)
      return comp.render(*args){ children }
    end

    def render_tag(tag_name, attributes, children)
      attributes = VDomBuilder.hash_to_js_obj(attributes || {})
      children ||= `null`
      ret = %x{
        {
          nodeName: tag_name,
          attributes: attributes,
          children: children,
          key: attributes.key
        }
      }
      ret
    end
  end

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

  class WiredActions
    def initialize(actions, app, runtime)
      @actions, @app, @runtime = actions, app, runtime
    end

    def method_missing(name, *args)
      invoke_action(name, *args)
    end

    def respond_to?(name)
      @actions.respond_to?(name)
    end

    private

    # Call action and schedule rendering
    def invoke_action(name, *args)
      new_state = @actions.__send__(name, @app.state, *args)
      @app._set_state(new_state)
      @runtime.scheduleRender
    end
  end
   
  class App
    def initialize
      @state = self.class.const_get('State').new
    end
    attr_reader :state

    # Internal use only
    def _set_state(new_state)
      @state = state
    end

    def run(id: nil)
      runtime = Ovto::Runtime.new(self)
      wired_actions = WiredActions.new(self.class.const_get('Actions').new, self, runtime)
      view = self.class.const_get('View').new(wired_actions)
      container = id && `document.getElementById(id)`
      runtime.run(view, container)
    end
  end

  def self.run(app_class, *args)
    app_class.new.run(*args)
  rescue Exception => ex
    div = `document.getElementById('ovto-debug')`
    `console.log(document.getElementById('ovto-debug'))`
    if `div && !ex.OvtoPrinted`
      %x{
        div.textContent = "ERROR: " + #{ex.class.name};
        var ul = document.createElement('ul');
        // Note: ex.backtrace may be an Array or a String
        #{Array(ex.backtrace)}.forEach(function(line){
          var li = document.createElement('li');
          li.textContent = line;
          ul.appendChild(li);
        });
        div.appendChild(ul);
        ex.OvtoPrinted = true;
      }
    end
    raise ex
  end
end
