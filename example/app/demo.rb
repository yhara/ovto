require 'opal'
require 'ovto'

class TodoApp < Ovto::App
  class State < Ovto::State
    item :todos, []
    item :filter, :all
    item :input, ""
  end

  class Todo < Ovto::State
    item :id
    item :value
    item :done
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

    def set_input(state, value)
      return state.merge(input: value)
    end

    def set_filter(state, value)
      return state.merge(filter: value)
    end
  end

  class View < Ovto::Component
    def render(state)
      o 'section.todoapp' do
        o 'header.header' do
          o 'h1', 'todos'
          o 'input.new-todo', placeholder: "What needs to be done?", autofocus: true
        end

        o 'section.main', style: 'display: none' do
          o 'input#toggle-all.toggle-all', type: 'checkbox'
          o 'label', {for: 'toggle-all'}, 'Mark all as complete'
          o 'ul.todo-list'
          o 'footer.footer' do
            o 'span.todo-count'
            o 'ul.filters' do
              o 'li' do
                o 'a.selected', {href: '#/'}, 'All'
              end
              o 'li' do
                o 'a', {href: '#/active'}, 'Active'
              end
              o 'li' do
                o 'a', {href: '#/completed'}, 'Active'
              end
            end
            o 'button.clear-completed', 'Clear completed'
          end
        end
      end
    end
  end
end

Ovto.run(TodoApp, id: 'todoapp')
