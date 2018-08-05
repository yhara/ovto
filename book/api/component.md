# Ovto::Component

Your app must have a `View` class, a subclass of `Ovto::Component`.

## 'render' method

`render` is the only method you need to define in the `View` class.
It must take the global app state as a keyword argument `state:`.

```rb
  class View < Ovto::Component
    def render(state:)
      o 'div' do
        o 'h1', 'Your todos'
        o 'ul' do
          state.todos.each do |todo|
            o 'li', todo.title
          end
        end
      end
    end
  end
```

### MoreThanOneNode error

If you missed the surrounding 'div' tag, Ovto raises an `MoreThanOneNode` error. `render` must create a single DOM node.

```rb
    def render(state:)
      o 'h1', 'Your todos'
      o 'ul' do
        state.todos.each do |todo|
          o 'li', todo.title
        end
      end
    end

#=> $MoreThanOneNode {name: "MoreThanOneNode", message: "MyApp::View#render must generate a single DOM node. Please wrap the tags with a 'div' or something.", stack: "MoreThanOneNode: MyApp::View#render must generate …opbox/proj/ovto/example/tutorial/app.js:22887:18)"}
```

## The 'o' method

<a name='the-o-method' />

`Ovto::Component#o` describes your app's view. For example:

```rb
o 'div'
#=> <div></div>

o 'div', 'Hello.'
#=> <div>Hello.</div>
```

You can pass attributes with a Hash.

```rb
o 'div', class: 'main', 'Hello.'
#=> <div class='main'>Hello.</div>
```

There are shorthand notations for classes and ids.

```rb
o 'div.main'
#=> <div class='main'>Hello.</div>

o 'div#main'
#=> <div id='main'>Hello.</div>
```

You can also give a block to specify its content.

```rb
o 'div' do
  'Hello.'
end
#=> <div>Hello.</div>

o 'div' do
  o 'h1', 'Hello.'
end
#=> <div><h1>Hello.</h1></div>
```

### Special attribute: `style`

<a name='special-attributes' />

There are some special keys for the attributes Hash. `style:` key takes a hash as 
its value and specifies styles of the tag.

```rb
o 'div', style: {color: 'red'}, 'Hello.'
#=> <div style='color: red;'>Hello.</div>
```

### Special attribute: `onxx`

An attribute starts with `"on"` specifies an event handler.

For example:

```rb
o 'input', {
  type: 'button',
  onclick: ->(e){ p e.target.value },
  value: 'Hello.'
}
```

The argument `e` is an instance of Opal::Native and wraps the JavaScript event object.
You can get the input value with `e.target.value` here.

#### Lifecycle events

There are special events `oncreate`, `onupdate`, `onremove`, `ondestroy`.

https://github.com/hyperapp/hyperapp#lifecycle-events

### Special attribute: `key`

https://github.com/hyperapp/hyperapp#keys

(Note: this feature is not tested yet)

## Sub components

`o` can take another component class to render.

```rb
  # Sub component
  class TodoList < Ovto::Component
    def render(todos:)
      o 'ul' do
        todos.each do |todo|
          o 'li', todo.title
        end
      end
    end
  end

  # Main View class
  class View < Ovto::Component
    def render(state:)
      o 'div' do
        o 'h1', 'Your todos'
        o TodoList, todos: state.todos
      end
    end
  end
```

Note that you cannot call `o` more than once in the `render` method  of sub components too.
In other words, sub component must yield a single DOM element.

## Text node

Sometimes you may want to create a text node.

```rb
#=> <div>Age: <span class='age'>12</a></div>
#        ~~~~~
#          |
#          +--Raw text (not enclosed by an inner tag)
```

`o` generates a text node when `'text'` is specified as tag name. The above
HTML could be described like this.

```rb
o 'div' do
  o 'text', 'Age:'
  o 'span', '12'
end
```

