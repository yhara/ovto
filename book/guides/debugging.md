# Debugging Ovto app

## console.log

In an Ovto app, you can print any object to developer console by `console.log`
like in JavaScript. 

```rb
console.log(state: State.new)
```

This is mostly equal to `p state: State.new` but `console.log` supports
JavaScript objects too.

(Note: this is not an official feature of Opal. You can do this setup by this:)

```rb
  require 'console'; def console; $console; end
```

## ovto-debug

If the page has a tag with `id='ovto-debug'`, exception is shown in the tag.
