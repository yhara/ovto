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
        children: nil,
      })
    end

    it 'attributes' do
      node = o("div", id: "foo")
      expect(node).to eq({
        nodeName: "div",
        attributes: {id: "foo"},
        children: nil,
      })
    end

    it 'content' do
      node = o("div", {}, "hi")
      expect(node).to eq({
        nodeName: "div",
        attributes: {},
        children: "hi",
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
