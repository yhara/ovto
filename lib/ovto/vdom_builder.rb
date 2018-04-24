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
    
    # o 'div', 'Hello.'
    # o 'div', class: 'main', 'Hello.'
    # o 'div.main'
    # o 'div#main'
    # o 'div' do 'Hello.' end
    # o 'div' do
    #   o 'h1', 'Hello.'
    # end
    def o(_tag_name, arg1=nil, arg2=nil, &block)
      if arg1.is_a?(Hash)
        attributes = arg1
        content = arg2
      elsif arg2 == nil
        attributes = {}
        content = arg1
      else
        raise ArgumentError
      end
      # Ignore nil/false
      attributes.reject!{|k, v| !v}

      children = render_children(content, block)
      case _tag_name
      when Class
        @result << render_component(_tag_name, attributes, children)
      when String
        tag_name, base_attributes = *extract_attrs(_tag_name)
        @result << render_tag(tag_name, base_attributes.merge(attributes), children)
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

    def extract_attrs(tag_name)
      case tag_name 
      when /^([^.#]+)\.([-_\w]+)(\#([-_\w]+))?/
        tag_name, class_name, id = $1, $2, $4
      when /^([^.#]+)\#([-_\w]+)(\.([-_\w]+))?/
        tag_name, class_name, id = $1, $4, $2
      else
        class_name = id = nil
      end
      attributes = {}
      attributes[:class] = class_name if class_name
      attributes[:id] = id if id
      return tag_name, attributes
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
