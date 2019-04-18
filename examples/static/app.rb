require 'ovto'

class MyApp < Ovto::App
  class State < Ovto::State
    item :celsius, default: 0

    def fahrenheit
      (celsius * 9 / 5.0) + 32
    end
  end

  class Actions < Ovto::Actions
    def set_celsius(value:)
      return {celsius: value}
    end

    def set_fahrenheit(value:)
      new_celsius = (value - 32) * 5 / 9.0
      return {celsius: new_celsius}
    end
  end

  class MainComponent < Ovto::Component
    def render
      o 'div' do
        o 'span', 'Celcius:'
        o 'input', {
          type: 'text',
          onchange: ->(e){ actions.set_celsius(value: e.target.value.to_i) },
          value: state.celsius
        }
        o 'span', 'Fahrenheit:'
        o 'input', {
          type: 'text',
          onchange: ->(e){ actions.set_fahrenheit(value: e.target.value.to_i) },
          value: state.fahrenheit
        }
      end
    end
  end
end

MyApp.run(id: 'ovto')
