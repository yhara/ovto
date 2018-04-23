require 'spec_helper'

module Ovto
  describe VDomBuilder do
    before do
      @comp = Component.new(nil)
    end

    def o(*args, &block)
      js_node = @comp.send(:o, *args, &block)
      return JSON.parse(`JSON.stringify(js_node)`)
    end

    it 'empty tag' do
      node = o("div")
      expect(node).to eq({
        nodeName: "div",
        attributes: {},
        children: [],
      })
    end

    describe 'tag_name' do
      it 'can have .class' do
        node = o("div.main")
        expect(node).to eq({
          nodeName: "div",
          attributes: {class: 'main'},
          children: [],
        })
      end

      it 'can have #id' do
        node = o("div#main")
        expect(node).to eq({
          nodeName: "div",
          attributes: {id: 'main'},
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

    it 'attributes' do
      node = o("div", id: "foo")
      expect(node).to eq({
        nodeName: "div",
        attributes: {id: "foo"},
        children: [],
      })
    end

    it 'content as argument' do
      node = o("div", {}, "hi")
      expect(node).to eq({
        nodeName: "div",
        attributes: {},
        children: ["hi"],
      })
    end

    it 'content in block' do
      node = o("div"){ "hi" }
      expect(node).to eq({
        nodeName: "div",
        attributes: {},
        children: ["hi"],
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

    it 'key'
    it 'onxx'
  end
end
