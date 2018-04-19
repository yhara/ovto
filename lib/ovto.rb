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
    end

    def initialize
      TODO
    end

    def merge(hash)
      TODO
    end

    def to_h

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

    def initialize(action_sender)
      @action_sender = action_sender
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

    private

    def render_children(content=nil, block=nil)
      return [] if !content && !block
      raise ArgumentError, "o cannot take both content and block" if content && block
      
      if content
        [content]
      else
        builder = VDomBuilder.new
        builder.instance_eval(&block)
        builder.result
      end
    end

    def render_component(comp_class, args, children)
      comp = comp_class.new(@action_sender)
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
    def initialize(action_sender)
      @actions = action_sender
    end

    def render
      ''
    end

    private

    def o(*args, &block)
      builder = VDomBuilder.new(@actions)
      builder.o(*args, &block)
      return builder.result.first
    end
  end

  class ActionSender
    def initialize(actions_module)
    end
  end
   
  class App
    def run(id: nil)
      container = id && `document.getElementById(id)`
      Ovto::Runtime.new(self).run(container)
    end

    def initial_state
      TODO
    end

    def view
      self.class.const_get('View').new
    end

    private

    def state_class
      self.class.const_get('State').new
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
