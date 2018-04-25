require 'opal'
require 'ovto'

class TodoApp < Ovto::App
  FILTERS = [:All, :Active, :Completed]

  class Todo < Ovto::State
    item :id
    item :value
    item :done
  end

  class State < Ovto::State
    item :todos, [Todo.new(id: 1, value: "aaa", done: false)]
    item :filter, FILTERS.first
    item :input, ""
  end

  class Actions
    def add_todo(state)
      new_todo = Todo.new(
        id: state.todos.length + 1,
        value: state.input,
        done: false
      )
      return state.merge(
        todos: state.todos + [new_todo],
        input: ""
      )
    end

    def toggle_todo(state, id:, value:)
      new_todos = state.todos.map{|t|
        if t.id == id
          t.merge(done: !value)
        else
          t
        end
      }
      return state.merge(todos: new_todos)
    end

    def toggle_all(state, done:)
      new_todos = state.todos.map{|t| t.merge(done: done)}
      return state.merge(todos: new_todos)
    end

    def set_input(state, value:)
      return state.merge(input: value)
    end

    def set_filter(state, value:)
      return state.merge(filter: value)
    end
  end

  class Header < Ovto::Component
    def render(input:)
      o 'header.header' do
        o 'h1', 'todos'
        o 'input.new-todo', {
          placeholder: "What needs to be done?",
          autofocus: true,
          value: input,
          onkeydown: ->(e){ actions.add_todo if `e.keyCode === 13` },
          oninput: ->(e){ actions.set_input(value: `e.target.value`) },
        }
      end
    end
  end

  class TodoItem < Ovto::Component
    def render(todo:)
      o 'li', {class: todo.done && 'completed'} do
        o 'div.view' do
          o 'input.toggle', type: 'checkbox', checked: todo.done, onchange: ->{}
          o 'label', todo.value
          o 'button.destroy', onclick: ->{ actions.destroy_todo(todo.id) }
        end
        o 'input.edit', {
          value: todo.value, #TODO
          onblur: ->{ handle_submit },
          onchange: ->{ handle_change },
          onkeydown: ->{ handle_keydown },
        }
      end
    end
  end

  class Main < Ovto::Component
    def render(todos:)
      o 'section.main' do
        o 'input#toggle-all.toggle-all', {
          type: 'checkbox',
          onchange: ->(e){ actions.toggle_all(done: `e.target.checked`) },
          checked: todos.all?(&:done)
        }
        o 'label', {for: 'toggle-all'}, 'Mark all as complete'
        o 'ul.todo-list' do
          todos.each do |todo|
            o TodoItem, key: todo.id, todo: todo
          end
        end
      end
    end
  end

  class Footer < Ovto::Component
    def render(left_count:, current_filter:)
      o 'footer.footer' do
        o 'span.todo-count' do
          o 'strong', left_count
          text ' item(s) left'
        end

        o 'ul.filters' do
          # TODO: key needed?
          FILTERS.each do |filter|
            o 'li' do
              klass = (filter == current_filter) && 'selected'
              o 'a', {href: '#/', class: klass}, filter
            end
          end
        end
        o 'button.clear-completed', 'Clear completed'
      end
    end
  end

  class View < Ovto::Component
    def render(state)
      o 'section.todoapp' do
        o Header,
          input: state.input
        o Main, 
          todos: state.todos
        o Footer,
          left_count: state.todos.count{|t| !t.done},
          current_filter: state.filter
      end
    end
  end
end

Ovto.run(TodoApp, id: 'todoapp')
