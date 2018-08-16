require 'spec_helper'

module Ovto
  describe Actions do
    class AppExample < Ovto::App
      class State < Ovto::State
        item :ct, default: 0
      end

      class Actions < Ovto::Actions
        def request_increment_counter(state:)
          actions.increment_counter()
          return nil
        end

        def increment_counter(state:)
          return {ct: state.ct + 1}
        end
      end
    end

    it 'can invoke another action' do
      app = Object.new
      runtime = Object.new
      actions = AppExample::Actions.new
      wired_actions = WiredActions.new(actions, app, runtime)
      actions.wired_actions = wired_actions
      state = AppExample::State.new

      allow(app).to receive(:state).and_return(state)
      allow(runtime).to receive(:scheduleRender)
      expect(app).to receive(:_set_state).with(AppExample::State.new(ct: 1))

      wired_actions.request_increment_counter(state: state)
    end
  end
end
