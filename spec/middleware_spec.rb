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
        def do_something
          return {msg: "#{state.msg} action."}
        end
      end

      class View < MiddlewareExample::Component
        def render
          # Note: Usually actions should be called inside event handlers.
          # Do not try this at home.
          actions.do_something

          "#{state.msg} view."
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

      result = app.main_component.do_render({}, :dummy)
      expect(result).to eq("middleware. action. view.")
      expect(app.state.msg).to eq("app action.")
      expect(app.state._middlewares.middleware_example.msg).to eq("middleware. action.")
    end

    it "middleware actions can be invoked from app" do
      runtime = Object.new
      expect(Ovto::Runtime).to receive(:new).and_return(runtime)
      allow(runtime).to receive(:run)
      allow(runtime).to receive(:scheduleRender)
      app = AppExample.new
      app.run
      app.actions.middleware_example.do_something

      expect(app.state.msg).to eq("app.")
      expect(app.state._middlewares.middleware_example.msg).to eq("middleware. action.")
    end

    context "when nested" do
      class MiddlewareA < Ovto::Middleware("middleware_a")
        class State < MiddlewareA::State
          item :msg, default: "middleware a"
          item :count, default: 0
        end

        class Actions < MiddlewareA::Actions
          def do_something
            return {msg: "#{state.msg} action."}
          end

          def increment_counter
            return {count: state.count + 1}
          end
        end

        class View < MiddlewareA::Component
          def render
            actions.increment_counter()
            "~ #{state.msg} ~"
          end
        end
      end

      class MiddlewareB < Ovto::Middleware("middleware_b")
        use MiddlewareA

        class State < MiddlewareB::State
          item :msg, default: "middleware b"
        end

        class Actions < MiddlewareB::Actions
          def do_something
            actions.middleware_a.do_something()
          end
        end

        class View < MiddlewareB::Component
          def render
            o MiddlewareA::View
          end
        end
      end

      class NestedMiddlewareExample < Ovto::App
        use MiddlewareB

        class State < Ovto::State; end
        class Actions < Ovto::Actions; end
        class MainComponent < Ovto::Component
          def render
            o MiddlewareB::View
          end
        end
      end

      it "each middleware has its own state" do
        runtime = Object.new
        expect(Ovto::Runtime).to receive(:new).and_return(runtime)
        allow(runtime).to receive(:run)
        allow(runtime).to receive(:scheduleRender)
        app = NestedMiddlewareExample.new
        app.run

        expect(app.state._middlewares.middleware_b.msg).to eq("middleware b")
        expect(app.state._middlewares.middleware_b
                        ._middlewares.middleware_a.msg).to eq("middleware a")
      end

      it "can call another middleware's action" do
        runtime = Object.new
        expect(Ovto::Runtime).to receive(:new).and_return(runtime)
        allow(runtime).to receive(:run)
        allow(runtime).to receive(:scheduleRender)
        app = NestedMiddlewareExample.new
        app.run

        app.actions.middleware_b.do_something

        expect(app.state._middlewares.middleware_b
                        ._middlewares.middleware_a.msg).to eq("middleware a action.")
      end

      it "can call middleware action from #render" do
        runtime = Object.new
        expect(Ovto::Runtime).to receive(:new).and_return(runtime)
        allow(runtime).to receive(:run)
        allow(runtime).to receive(:scheduleRender)
        app = NestedMiddlewareExample.new
        app.run

        app.main_component.do_render({}, :dummy)
        expect(app.state._middlewares.middleware_b
                        ._middlewares.middleware_a.count).to eq(1)
      end
    end
  end
end
