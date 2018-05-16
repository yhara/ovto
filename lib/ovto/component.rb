module Ovto
  class Component
    # `render` tried to yield multiple nodes
    class MoreThanOneNode < StandardError; end

    def self.hash_to_js_obj(hash)
      ret = `{}`
      hash.each do |k, v|
        `ret[k] = v`
      end
      ret
    end

    def initialize(wired_actions)
      @wired_actions = wired_actions
      # Initialize here for the unit tests
      @vdom_tree = []
    end

    def render
      ''
    end

    private

    def do_render(state)
      @vdom_tree = []
      @done_render = false
      return render(state: state)
    end

    def actions
      @wired_actions
    end

    # o 'div', 'Hello.'
    # o 'div', class: 'main', 'Hello.'
    # o 'div', style: {color: 'red'}, 'Hello.'
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
        result = render_component(_tag_name, attributes, children)
      when 'text'
        unless attributes.empty?
          raise ArgumentError, "text cannot take attributes"
        end
        result = content
      when String
        tag_name, base_attributes = *extract_attrs(_tag_name)
        result = render_tag(tag_name, base_attributes.merge(attributes), children)
      else
        raise TypeError, "tag_name must be a String or Component but got "+
          Ovto.inspect(tag_name)
      end
      if @vdom_tree.empty?
        if @done_render
          raise MoreThanOneNode, "#{self.class}#render must generate a single DOM node. Please wrap the tags with a 'div' or something."
        end
        @done_render = true
        return result
      else
        @vdom_tree.last.push(result)
        return @vdom_tree.last
      end
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
      case
      when content && block
        raise ArgumentError, "o cannot take both content and block"
      when content
        return Array(content)
      when block
        @vdom_tree.push []
        block_value = block.call
        results = @vdom_tree.pop
        if results.length > 0 
          results 
        else
          # When 'o' is never called in the child block, use the last value 
          # eg. 
          #   o 'span' do
          #     'Hello'  #=> This will be the content of the span tag
          #   end
          [block_value]
        end
      else
        []
      end
    end

    def render_component(comp_class, args, children)
      comp = comp_class.new(@wired_actions)
      return comp.render(**args){ children }
    end

    def render_tag(tag_name, attributes, children)
      js_attributes = Component.hash_to_js_obj(attributes || {})
      if (style = attributes['style'])
        `js_attributes.style = #{Component.hash_to_js_obj(style)}`
      end
      children ||= `null`
      ret = %x{
        {
          nodeName: tag_name,
          attributes: js_attributes,
          children: children,
          key: js_attributes.key
        }
      }
      ret
    end
  end
end
