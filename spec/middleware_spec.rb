require 'spec_helper'

module Ovto
  describe Middleware do
    describe ".name" do
      class Middleware1 < Ovto::Middleware("middleware1"); end
      class Middleware2 < Ovto::Middleware("middleware2"); end
      it "should return name of each middleware" do
        expect(Middleware1.name).to eq("middleware1")
        expect(Middleware2.name).to eq("middleware2")
      end
    end

    class MiddlewareExample < Ovto::Middleware("middleware_example")
      class State < MiddlewareExample::State
        item :msg, default: "middleware."
      end

      class Actions < MiddlewareExample::Actions
        def do_something(state:)
          return {msg: "middleware action."}
        end
      end

      class View < MiddlewareExample::Component
        def render
          # Note: Usually actions should be called inside event handlers.
          # Do not try this at home.
          actions.do_something

          "middleware view."
        end
      end
    end

    class AppExample < Ovto::App
      use MiddlewareExample

      class State < Ovto::State
        item :msg, default: "app."
      end

      class Actions < Ovto::Actions
        def do_something(state:)
          return {msg: "app action."}
        end
      end

      class MainComponent < Ovto::Component
        def render
          o MiddlewareExample::View
        end
      end
    end

    it "has its own namespace of state and actions" do
      runtime = Object.new
      expect(Ovto::Runtime).to receive(:new).and_return(runtime)
      allow(runtime).to receive(:run)
      allow(runtime).to receive(:scheduleRender)
      app = AppExample.new
      app.run
      app.actions.do_something(state: app.state)

      app.main_component.do_render({}, :dummy)
      expect(app.state.msg).to eq("app action.")
      expect(app.state._middlewares.middleware_example.msg).to eq("middleware action.")
    end

    it "middleware actions can be invoked from app" do
      runtime = Object.new
      expect(Ovto::Runtime).to receive(:new).and_return(runtime)
      allow(runtime).to receive(:run)
      allow(runtime).to receive(:scheduleRender)
      app = AppExample.new
      app.run
      app.actions.middleware_example.do_something(state: app.state)

      expect(app.state.msg).to eq("app.")
      expect(app.state._middlewares.middleware_example.msg).to eq("middleware action.")
    end
  end
end
