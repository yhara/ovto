module Ovto
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
      when Class
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
        Array(content)
      else
        builder = VDomBuilder.new(@wired_actions)
        value = builder.instance_eval(&block)
        builder.result == [] ? [value] : builder.result
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
end
