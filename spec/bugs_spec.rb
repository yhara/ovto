require 'spec_helper'

module Ovto
  describe "bug" do
    describe "action in sub component" do
      class Bug1 < Ovto::App
        class State < Ovto::State; end
        class Actions < Ovto::Actions
          def foo; end
        end
        class SubComponent < Ovto::Component
          def render
            actions.foo
            "ok"
          end
        end
        class MainComponent < Ovto::Component
          def render
            o SubComponent
          end
        end
      end

      it "should not raise error" do
        runtime = Object.new
        expect(Ovto::Runtime).to receive(:new).and_return(runtime)
        allow(runtime).to receive(:run)
        allow(runtime).to receive(:scheduleRender)

        app = Bug1.new
        app.run
        result = app.main_component.do_render({}, :dummy)
        expect(result).to eq("ok")
      end
    end
  end
end
