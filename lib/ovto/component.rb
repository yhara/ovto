require 'native'

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
      @components = []
      @components_index = 0
    end

    def render
      ''
    end

    def state
      @wired_actions._app.state
    end

    private

    # Render entire MyApp::MainComponent
    # Called from runtime.rb
    def render_view(state)
      do_render({}, state)
    end

    def do_render(args, state)
      Ovto.debug_trace_log("rendering #{self}")
      @vdom_tree = []
      @components_index = 0
      @done_render = false
      @current_state = state
      parameters = method(:render).parameters
      if `!parameters` || parameters.nil? || accepts_state?(parameters)
        # We can pass `state:` safely
        args_with_state = {state: @current_state}.merge(args)
        return render(args_with_state)
      else
        # Check it is empty (see https://github.com/opal/opal/issues/1872)
        return args.empty? ? render() : render(**args)
      end
    end

    # Return true if the method accepts `state:` keyword
    def accepts_state?(parameters)
      parameters.each do |item|
        return true if item == [:key, :state] ||
                       item == [:keyreq, :state] ||
                       item[0] == :keyrest
      end
      return false
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
    # o 'div', `{nodeName: ....}`   # Inject VDom spec directly
    def o(_tag_name, arg1=nil, arg2=nil, &block)
      if native?(arg1)
        attributes = {}
        content = arg1
      elsif arg1.is_a?(Hash)
        attributes = arg1
        content = arg2
      elsif arg2 == nil
        attributes = {}
        content = arg1
      else
        raise ArgumentError
      end

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
        # Ignore nil/false
        more_attributes = attributes.reject{|k, v| !v}
        result = render_tag(tag_name, merge_attrs(base_attributes, more_attributes), children)
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
      when /^([^.#]*)\.([-\w]+)(\#([-\w]+))?/  # a.b#c
        tag_name, class_name, id = ($1.empty? ? 'div' : $1), $2, $4
      when /^([^.#]*)\#([-\w]+)(\.([-\w]+))?/  # a#b.c
        tag_name, class_name, id = ($1.empty? ? 'div' : $1), $4, $2
      else
        class_name = id = nil
      end
      attributes = {}
      attributes[:class] = class_name if class_name
      attributes[:id] = id if id
      return tag_name, attributes
    end

    # Merge attributes into base_attributes, with special care for `class:`
    def merge_attrs(base_attributes, attributes)
      base_class = base_attributes[:class]
      more_class = attributes[:class]
      merged_class = if base_class && more_class
                       base_class + " " + more_class
                     else
                       base_class || more_class
                     end
      if merged_class
        base_attributes.merge(attributes).merge(:class => merged_class)
      else
        base_attributes.merge(attributes)
      end
    end

    def render_children(content=nil, block=nil)
      case
      when content && block
        raise ArgumentError, "o cannot take both content and block"
      when content
        if native?(content)
          [content]
        else
          [content.to_s]
        end
      when block
        render_block(block)
      else
        []
      end
    end

    def render_block(block)
      @vdom_tree.push []
      block_value = block.call
      results = @vdom_tree.pop
      if results.length > 0   # 'o' was called at least once
        results 
      elsif native?(block_value)
        # Inject VDom tree written in JS object
        # eg. Embed markdown
        [block_value]
      elsif block_value.is_a?(String)
        # When 'o' is never called in the child block, use the last value 
        # eg. 
        #   o 'span' do
        #     'Hello'  #=> This will be the content of the span tag
        #   end
        [block_value]
      else
        #   o 'div' do
        #     # When items is `[]`, 'o' is never called and `block_value` will be `[]`
        #     items.each{ o 'div', '...' }
        #   end
        []
      end
    end

    def render_component(comp_class, args, children)
      comp = new_component(comp_class)
      return comp.do_render(args, @current_state){ children }
    end

    def new_component(comp_class)
      comp = @components[@components_index]
      if comp.is_a?(comp_class)
        @components_index += 1
        return comp
      end

      comp = @components[@components_index] = comp_class.new(@wired_actions)
      @components_index += 1
      comp
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
