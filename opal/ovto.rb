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

    def result
      if @result.length <= 1
        @result.first
      else
        @result
      end
    end
    
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
      return nil if !content && !block
      raise ArgumentError, "o cannot take both content and block" if content && block
      
      if content
        content
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
      return builder.result
    end
  end

  class MainComponent < Component
    def render(state)
      ''
    end
  end

  class ActionSender
    def initialize(actions_module)
    end
  end
   
  class App
    def initialize(initial_state, actions_module, main_component_class)
      @initial_state = initial_state
      @actions = actions
      @main_component_class = main_component_class
    end

    def run(dom)
      # schedule_render
    end
  end
end
