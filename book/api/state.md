# Ovto::State

`Ovto::State` is like a hash, but members are accessible with name rather than `[]`.

## Example

```rb
class State < Ovto::State
  item :foo
  item :bar
end

state = State.new(foo: 1, bar: 2)
state.foo  #=> 1
state.bar  #=> 2
```

## Default value


```rb
class State < Ovto::State
  item :foo, default: 1
  item :bar, default: 2
end

state = State.new
state.foo  #=> 1
state.bar  #=> 2
```

## Immutable

State objects are immutable. i.e. you cannot update value of a key. Instead, use `State#merge`.

```rb
state = State.new(foo: 1, bar: 2)
new_state = state.merge(bar: 3)
new_state.foo  #=> 1
new_state.bar  #=> 3
```

## Nesting state

For practical apps, you can nest State like this.

```rb
class Book < Ovto::State
  item :title
  item :author
end

class State < Ovto::State
  item :books, []
end

book = Book.new('Hello world', 'taro')
state = State.new(books: [book])
```

## Defining instance methods of state

You can define instance methods of state.

```rb
class Book < Ovto::State
  item :title
  item :author

  def to_text
    "#{self.title} (#{self.author})"
  end
end

book = Book.new('Hello world', 'taro')
book.to_text  #=> "Hello world (taro)"
```

## Defining class methods of state

Ovto does not have a class like `StateList`. Just use Array to represent a list of state.

You can define class methods to manipulate a list of state.

```rb
class Book < Ovto::State
  item :title
  item :author

  def self.of_author(books, author)
    books.select{|x| x.author == author}
  end
end

# Example
taro_books = Book.of_author(books, "taro")
```
