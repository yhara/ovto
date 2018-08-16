require 'spec_helper'

module Ovto
  describe Component do
    context '#render' do
      it "cannot yield more than one node" do
        class MultipleO < Component
          def render(state)
            o 'div' 
            o 'span' 
          end
        end
        expect {
          MultipleO.new(nil).do_render(nil)
        }.to raise_error(Component::MoreThanOneNode)
      end

      it "second rendering" do
        class CallingTwice < Component
          def render(state)
            o 'div' 
          end
        end
        comp = CallingTwice.new(nil)
        comp.do_render(nil)
        node = js_obj_to_hash(comp.do_render(nil))
        expect(node).to eq(
          {nodeName: "div", attributes: {}, children: []},
        )
      end
    end
  end
end
