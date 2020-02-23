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

    # (internal) Defined for convenience
    def self.middleware_name
      WiredActionSet::I_AM_APP_NOT_A_MIDDLEWARE
    end

    def initialize(wired_action_set, middleware_path=[])
      @wired_action_set = wired_action_set || WiredActionSet.dummy
      @middleware_path = middleware_path
      # Initialize here for the unit tests
      @vdom_tree = []
      @components = []
      @components_index = 0
    end

    def render
      ''
    end

    def state
      @wired_action_set.app.state
    end

    private

    # Render entire MyApp::MainComponent
    # Called from runtime.rb
    def render_view(state)
      do_render({}, state)
    end

    # Call #render to generate VDom
    def do_render(args, state, &block)
      Ovto.debug_trace_log("rendering #{self}")
      @vdom_tree = []
      @components_index = 0
      @done_render = false
      @current_state = state
      return Ovto.log_error {
        Ovto.send_args_with_state(self, :render, args, state, &block)
      }
    end

    def actions
      return @middleware_path.inject(@wired_action_set){|wa_set, middleware_name|
        wa_set[middleware_name]
      }[WiredActionSet::THE_MIDDLEWARE_ITSELF]
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
    # o SubComponentClass
    # o SubComponentClass do ... end  # Ovto passes the block to SubComponent#render
    def o(_tag_name, arg1=nil, arg2=nil, &block)
      if native?(arg1)   # Embed VDom directly
        attributes = {}
        content = arg1
      elsif arg1.is_a?(Hash)  # Has attributes
        attributes = arg1
        content = arg2
      elsif arg2 == nil  # Has content instead of attributes, or both are nil
        attributes = {}
        content = arg1
      else
        raise ArgumentError
      end

      case _tag_name
      when Class
        if content
          raise ArgumentError, "use a block to pass content to sub component"
        end
        result = render_component(_tag_name, attributes, &block)
      when 'text'
        unless attributes.empty?
          raise ArgumentError, "text cannot take attributes"
        end
        result = content
      when String
        children = render_children(content, block)
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
      block_value = instance_eval(&block)
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
      elsif block_value.is_a?(Array)
        # Case 1
        #   o "div", &block
        # Case 2
        #   items = []
        #   o 'div' do items.each{ o ... } end  # == o 'div' do [] end
        block_value
      else
        console.error("Invalid block_value:", Ovto.inspect(block_value))
        raise "Invalid block value"
      end
    end

    # Instantiate component and call its #render to get VDom
    def render_component(comp_class, args, &block)
      comp = new_component(comp_class)
      return comp.do_render(args, @current_state, &block)
    end

    def new_component(comp_class)
      comp = @components[@components_index]
      if comp.is_a?(comp_class)
        @components_index += 1
        return comp
      end

      middleware_path = new_middleware_path(comp_class)
      comp = @components[@components_index] = comp_class.new(@wired_action_set, middleware_path)
      @components_index += 1
      comp
    end

    # Make new middleware_path by adding comp_class
    def new_middleware_path(comp_class)
      mw_name = comp_class.middleware_name
      if (idx = @middleware_path.index(mw_name))
        # eg. suppose OvtoIde uses OvtoWindow
        #   class CompI < OvtoIde::Component
        #     def render
        #       o Window do 
        #         o AnotherComponentOfOvtoIde
        #       end
        #     end
        #   end
        #   class Window < OvtoWindow::Component
        #     def render(&block)
        #       o ".window", &block
        #     end
        #   end
        # Rendering order:
        #   1. CompI (ovto_ide)
        #   2. Window (ovto_window)
        #   3. AnotherComponentOfOvtoIde (ovto_ide again)
        @middleware_path[0..idx]
      else
        @middleware_path + [comp_class.middleware_name]
      end
      # TODO: it would be nice if we could raise an error when comp_class
      # is invalid middleware (i.e. not use'd)
    end

    def render_tag(tag_name, attributes, children)
      attributes_ = attributes.map{|k, v|
        if k.start_with?("on")
          # Inject log_error to event handlers
          [k, ->(e){ Ovto.log_error{ v.call(e) }}]
        else
          [k, v]
        end
      }.to_h
      js_attributes = Component.hash_to_js_obj(attributes_ || {})
      if (style = attributes_['style'])
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
