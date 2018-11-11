require 'spec_helper'

module Ovto
  describe Component do
    context '#render' do
      it "cannot yield more than one node" do
        class MultipleO < Component
          def render
            o 'div' 
            o 'span' 
          end
        end
        expect {
          MultipleO.new(nil).do_render(state: nil)
        }.to raise_error(Component::MoreThanOneNode)
      end

      it "second rendering" do
        class CallingTwice < Component
          def render
            o 'div' 
          end
        end
        comp = CallingTwice.new(nil)
        comp.do_render(state: nil)
        node = js_obj_to_hash(comp.do_render(state: nil))
        expect(node).to eq(
          {nodeName: "div", attributes: {}, children: []},
        )
      end

      it "empty block" do
        class EmptyBlock < Component
          def render
            o 'div' do end
          end
        end
        comp = EmptyBlock.new(nil)
        comp.do_render(state: nil)
        node = js_obj_to_hash(comp.do_render(state: nil))
        expect(node).to eq(
          {nodeName: "div", attributes: {}, children: []},
        )
      end
    end

    context "when rendering child component" do
      it "should pass around app state " do
        class ExampleApp
          class State < Ovto::State
            item :foo
          end

          class ParentComp < Component
            def render
              o ChildComp
            end
          end

          class ChildComp < Component
            def render(state:)
              "foo is #{state.foo}"
            end
          end
        end

        state = ExampleApp::State.new(foo: 1)
        ret = ExampleApp::ParentComp.new(nil).do_render(state: state)
        expect(ret).to eq("foo is 1")
      end

      it "can pass falsy value as attribute" do
        class ExampleApp
          class ParentComp < Component
            def render
              o 'div' do
                o ChildComp, foo: true
                o ChildComp, foo: false
                o ChildComp, foo: nil
              end
            end
          end

          class ChildComp < Component
            def render(foo:)
              foo.inspect
            end
          end
        end

        ret = ExampleApp::ParentComp.new(nil).do_render(state: :dummy)
        expect(`JSON.stringify(ret)`).to eq('{"nodeName":"div","attributes":{},"children":["true","false","nil"]}')
      end
    end
  end
end
