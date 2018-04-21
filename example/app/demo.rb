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

  class TodoItem < Ovto::Component
    def render(todo)
      onclick = ->{ actions.toggle_todo(value: todo.done, id: todo.id); false }
      o 'li', class: (todo.done && "done"), onclick: onclick do
        todo.value
      end
    end
  end

  class View < Ovto::Component
    def render(state)
      o 'div' do
        o 'h1', {}, 'Todo'

        o 'div', class: "flex" do
          o 'input', {
            type: "text",
            onkeyup: ->(e){ `e.keyCode === 13` ? actions.add_todo : "" },
            oninput: ->(e){ actions.set_input(`e.target.value`) },
            value: state.input,
            placeholder: "Do that thing...",
          }
          o 'button', {onclick: ->(e){ actions.add_todo }}, '＋'
        end

        o 'p' do
          o 'ul' do
            todos = state.todos.select{|t|
               case state.filter
               when :done then t.done
               when :todo then !t.done
               when :all then true
               end
            }
            todos.each do |t|
              o TodoItem, t
            end
          end
        end
      end
    end
  end
end

Ovto.run(TodoApp, id: 'ovto-main')
