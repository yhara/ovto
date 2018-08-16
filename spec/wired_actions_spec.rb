require 'spec_helper'

module Ovto
  describe WiredActions do
    class AppExample < Ovto::App
      class State < Ovto::State
        item :ct, default: 0
      end

      class Actions < Ovto::Actions
        def increment_counter(state:)
          return {ct: state.ct + 1}
        end

        def reset_counter(state:)
          return {ct: 0}
        end
      end
    end

    it 'has proxy methods to actions' do
      app = Object.new
      runtime = Object.new
      wired_actions = WiredActions.new(AppExample::Actions.new, app, runtime)
      state = AppExample::State.new

      allow(app).to receive(:state).and_return(state)
      expect(runtime).to receive(:scheduleRender)
      expect(app).to receive(:_set_state).with(AppExample::State.new(ct: 1))

      ret = wired_actions.increment_counter(state: state)
      expect(ret).to eq(AppExample::State.new(ct: 1))
    end

    it 'does not call scheduleRender if no state change' do
      app = Object.new
      runtime = Object.new
      wired_actions = WiredActions.new(AppExample::Actions.new, app, runtime)
      state = AppExample::State.new(ct: 0)

      allow(app).to receive(:state).and_return(state)
      expect(runtime).not_to receive(:scheduleRender)
      expect(app).not_to receive(:_set_state)

      wired_actions.reset_counter(state: state)
    end
  end
end
