# Ovto::PureComponent

It almost the same as `Ovto::Component`, but it caches the `render` method calling with arguments of the method.


## Cache strategy

It compares `render` method arguments and the previous arguments.

```rb
def render
  o 'div' do
    o Pure, foo: state.foo
    o NotPure bar: state.bar
  end
end
```

In this case, `NotPure` component's render method is called even if `state.foo` is changed.
Whereas `Pure` component's render method is called only if `state.foo` is changed.


## State

`state` method is not available in `PureComponent`, because `PureComponent` does not treat state as the cache key.
If you'd like to use state in `PureComponent`, pass the state from the parent component.

