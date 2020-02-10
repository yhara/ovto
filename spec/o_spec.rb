require 'spec_helper'

module Ovto
  describe 'The o method' do
    before do
      @comp = Component.new(nil)
    end

    def _o(*args, &block)
      return @comp.send(:o, *args, &block)
    end

    it 'empty tag' do
      node = _o("div")
      expect(js_obj_to_hash node).to eq({
        nodeName: "div",
        attributes: {},
        children: [],
      })
    end

    describe 'tag_name' do
      it 'can have .class and #id' do
        node = _o("div.main#app")
        expect(js_obj_to_hash node).to eq({
          nodeName: "div",
          attributes: {class: 'main', id: 'app'},
          children: [],
        })
      end

      it 'can have #id and .class' do
        node = _o("div#app.main")
        expect(js_obj_to_hash node).to eq({
          nodeName: "div",
          attributes: {class: 'main', id: 'app'},
          children: [],
        })
      end

      it 'can have #id but may be superceded by attributes' do
        node = _o("div#main", {id: 'main2'})
        expect(js_obj_to_hash node).to eq({
          nodeName: "div",
          attributes: {id: 'main2'},
          children: [],
        })
      end

      it 'can have .class and more classes in attributes' do
        node = _o("div.main", {class: 'hovered'})
        expect(js_obj_to_hash node).to eq({
          nodeName: "div",
          attributes: {class: 'main hovered'},
          children: [],
        })
      end
    end

    describe 'attributes' do
      it 'is ignored if the value is falsy' do
        node = _o("div", id: "foo", class: nil)
        expect(js_obj_to_hash node).to eq({
          nodeName: "div",
          attributes: {id: "foo"},
          children: [],
        })
      end

      it 'style is special attr which yields js obj' do
        node = _o("div", style: {color: 'red'})
        expect(js_obj_to_hash node).to eq({
          nodeName: "div",
          attributes: {style: {color: 'red'}},
          children: [],
        })
      end
    end

    describe 'content' do
      it 'content as argument' do
        node = _o("div", {}, "hi")
        expect(js_obj_to_hash node).to eq({
          nodeName: "div",
          attributes: {},
          children: ["hi"],
        })
      end

      it 'content as argument (attributes ommited)' do
        node = _o("div", "hi")
        expect(js_obj_to_hash node).to eq({
          nodeName: "div",
          attributes: {},
          children: ["hi"],
        })
      end

      it 'content as argument (passing non-string object)' do
        node = _o("div", {}, 3)
        expect(js_obj_to_hash node).to eq({
          nodeName: "div",
          attributes: {},
          children: ["3"],
        })
      end

      it 'content in block (single string)' do
        node = _o("div"){ "hi" }
        expect(js_obj_to_hash node).to eq({
          nodeName: "div",
          attributes: {},
          children: ["hi"],
        })
      end

      it "content in block (multiple o's)" do
        node = _o("div"){ o "div"; o "span" }
        expect(js_obj_to_hash node).to eq({
          nodeName: "div",
          attributes: {},
          children: [
            {nodeName: "div", attributes: {}, children: []},
            {nodeName: "span", attributes: {}, children: []},
          ]
        })
      end

      it 'content in block (eventually empty)' do
        items = []
        node = _o("div") do
          items.each do
            o "span", "(this message is never used because items is empty)"
          end
        end
        expect(js_obj_to_hash node).to eq({
          nodeName: "div",
          attributes: {},
          children: [],
        })
      end

      it 'nested' do
        node = _o "div" do
          o "pre", :foo
        end
        expect(js_obj_to_hash node).to eq({
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
        node = _o('text', 'foo')
        expect(js_obj_to_hash node).to eq('foo')
      end

      it 'in a block' do
        node = _o('span'){ o('text', 'foo') }
        expect(js_obj_to_hash node).to eq({
          nodeName: "span",
          attributes: {},
          children: ['foo']
        })
      end
    end
  end
end

