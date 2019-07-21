require 'spec_helper'

module Ovto
  describe PureComponent do
    let(:klass) do
      Class.new(PureComponent) do
        @render_count = 0

        def self.render_count
          @render_count
        end

        def self.increment_render_count
          @render_count += 1
        end

        def render(name:)
          self.class.increment_render_count
          o 'h1', name
        end
      end
    end

    describe '#render' do
      it 'returns a tree' do
        comp = klass.new(nil)
        node = js_obj_to_hash(comp.do_render({name: 'foo'}, nil))
        expect(node).to eq(
          {nodeName: "h1", attributes: {}, children: ['foo']},
        )
      end

      context 'when it called twice' do

        context 'with the same args' do
          it "uses cache" do
            comp = klass.new(nil)
            comp.do_render({name: 'foo'}, nil)
            node = js_obj_to_hash(comp.do_render({name: 'foo'}, nil))
            expect(node).to eq(
              {nodeName: "h1", attributes: {}, children: ['foo']},
            )
            expect(klass.render_count).to eq(1)
          end
        end

        context 'with different args' do
          it 'does not use cache' do
            comp = klass.new(nil)
            node = js_obj_to_hash(comp.do_render({name: 'foo'}, nil))
            expect(node).to eq(
              {nodeName: "h1", attributes: {}, children: ['foo']},
            )

            node = js_obj_to_hash(comp.do_render({name: 'bar'}, nil))
            expect(node).to eq(
              {nodeName: "h1", attributes: {}, children: ['bar']},
            )
            expect(klass.render_count).to eq(2)
          end
        end
      end

      context 'when it accesses the state' do
        it 'raises an error' do
          klass = Class.new(PureComponent) do
            def render
              o 'div', state.name
            end
          end

          comp = klass.new(nil)
          expect {
            comp.do_render({}, nil)
          }.to raise_error(PureComponent::StateIsNotAvailable)
        end
      end

      context 'when it is nested' do
        it 'uses cache' do
          klass = klass() # Necessary to access klass from Class.new
          parent = Class.new(Component) do
            CHILD = klass
            def render
              o CHILD, name: 'foo'
            end
          end

          comp = parent.new(nil)
          comp.do_render({}, nil)
          node = js_obj_to_hash(comp.do_render({}, nil))
          expect(node).to eq(
            {nodeName: "h1", attributes: {}, children: ['foo']},
          )
          expect(klass.render_count).to eq(1)
        end
      end
    end
  end
end
