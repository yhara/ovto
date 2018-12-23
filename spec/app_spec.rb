require 'spec_helper'

module Ovto
  describe App do
    class AppExample < Ovto::App
      class State < Ovto::State
        item :ct, default: 0
      end

      class Actions < Ovto::Actions
        def increment_counter(state:)
          return {ct: state.ct + 1}
        end
      end

      class MainComponent < Ovto::Component
        def render
          'hi'
        end
      end
    end

    it '#actions' do
      runtime = Object.new
      expect(Ovto::Runtime).to receive(:new).and_return(runtime)
      allow(runtime).to receive(:run)
      allow(runtime).to receive(:scheduleRender)

      app = AppExample.new
      app.run
      app.actions.increment_counter
      expect(app.state.ct).to eq(1)
    end
  end
end

