require 'spec_helper'

module Ovto
  describe Component do
    before do
      @comp = Component.new(nil)
    end

    def js_obj_to_hash(obj)
      JSON.parse(`JSON.stringify(obj)`)
    end

    def o(*args, &block)
      js_node = @comp.send(:o, *args, &block)
      return js_obj_to_hash(js_node)
    end

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

    context '#o' do
      it 'empty tag' do
        node = o("div")
        expect(node).to eq({
          nodeName: "div",
          attributes: {},
          children: [],
        })
      end

      describe 'tag_name' do
        it 'can have .class and #id' do
          node = o("div.main#app")
          expect(node).to eq({
            nodeName: "div",
            attributes: {class: 'main', id: 'app'},
            children: [],
          })
        end

        it 'can have #id and .class' do
          node = o("div#app.main")
          expect(node).to eq({
            nodeName: "div",
            attributes: {class: 'main', id: 'app'},
            children: [],
          })
        end

        it 'can have #id but may be superceded by attributes' do
          node = o("div#main", {id: 'main2'})
          expect(node).to eq({
            nodeName: "div",
            attributes: {id: 'main2'},
            children: [],
          })
        end
      end

      describe 'attributes' do
        it 'is ignored if the value is falsy' do
          node = o("div", id: "foo", class: nil)
          expect(node).to eq({
            nodeName: "div",
            attributes: {id: "foo"},
            children: [],
          })
        end

        it 'style is special attr which yields js obj' do
          node = o("div", style: {color: 'red'})
          expect(node).to eq({
            nodeName: "div",
            attributes: {style: {color: 'red'}},
            children: [],
          })
        end
      end

      describe 'content' do
        it 'content as argument' do
          node = o("div", {}, "hi")
          expect(node).to eq({
            nodeName: "div",
            attributes: {},
            children: ["hi"],
          })
        end

        it 'content as argument (attributes ommited)' do
          node = o("div", "hi")
          expect(node).to eq({
            nodeName: "div",
            attributes: {},
            children: ["hi"],
          })
        end

        it 'content in block (single string)' do
          node = o("div"){ "hi" }
          expect(node).to eq({
            nodeName: "div",
            attributes: {},
            children: ["hi"],
          })
        end

        it "content in block (multiple o's)" do
          node = o("div"){ o "div"; o "span" }
          expect(node).to eq({
            nodeName: "div",
            attributes: {},
            children: [
              {nodeName: "div", attributes: {}, children: []},
              {nodeName: "span", attributes: {}, children: []},
            ]
          })
        end

        it 'contents' do
          node = o("div", {}, ["hello", "world"])
          expect(node).to eq({
            nodeName: "div",
            attributes: {},
            children: ["hello", "world"],
          })
        end

        def foo; :foo; end
        it 'nested' do
          node = o "div" do
            o "pre", foo
          end
          expect(node).to eq({
            nodeName: "div",
            attributes: {},
            children: [{
              nodeName: "pre",
              attributes: {},
              children: ["foo"]
            }]
          })
        end
      end

      describe 'text' do
        it 'on the toplevel' do
          node = o('text', 'foo')
          expect(node).to eq('foo')
        end

        it 'in a block' do
          node = o('span'){ o('text', 'foo') }
          expect(node).to eq({
            nodeName: "span",
            attributes: {},
            children: ['foo']
          })
        end
      end

      it 'key'
      it 'onxx'
    end
  end
end
