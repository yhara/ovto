# vim: set ft=javascript:
require 'native'
module Ovto
  class Runtime
    def initialize(app)
      @app = app
    end

    def run(view, container)
      getState = ->{ @app.state }
      @scheduleRender = `Ovto.run(getState, view, container)`
    end

    def scheduleRender
      # An action is invoked before Ovto::Runtime#run.
      # Do nothing here because `scheduleRender` will eventually be called by #run
      return unless @scheduleRender

      @scheduleRender.call
    end
  end
end

# Core part
# Copied from https://github.com/hyperapp/hyperapp/blob/6c4f4fb927b0ebba69cb6397ee8c1b69a9e81e18/src/index.js (see LICENSE.txt) and added some modification
# TODO: should we use https://github.com/jorgebucaran/ultradom instead?
%x{
  var Ovto = {};
  Ovto.run = function(getState, view, container) {
    var map = [].map
    var rootElement = (container && container.children[0]) || null
    var oldNode = rootElement && recycleElement(rootElement)
    var lifecycle = []
    var skipRender
    var isRecycling = true

    scheduleRender()

    return scheduleRender

    function recycleElement(element) {
      return {
        nodeName: element.nodeName.toLowerCase(),
        attributes: {},
        children: map.call(element.childNodes, function(element) {
          return element.nodeType === 3 // Node.TEXT_NODE
            ? element.nodeValue
            : recycleElement(element)
        })
      }
    }

    function resolveNode(node) {
      if (node === Opal.nil || node == null) {
        return "";
      }
      else if (node.$$id) { // is a Opal obj
        if (node.$render_view) {
          return node.$render_view(getState());
        }
        else {
          throw "resolveNode: render_view not defined on " + node.$inspect();
return "";
        }
      }
      else {
        return node;
      }
    }

    function render() {
      skipRender = !skipRender

      var node = resolveNode(view)

      if (container && !skipRender) {
        rootElement = patch(container, rootElement, oldNode, (oldNode = node))
      }

      isRecycling = false

      while (lifecycle.length) lifecycle.pop()()
    }

    function scheduleRender() {
      if (!skipRender) {
        skipRender = true
        setTimeout(render)
      }
    }

    function clone(target, source) {
      var out = {}

      for (var i in target) out[i] = target[i]
      for (var i in source) out[i] = source[i]

      return out
    }

    function getKey(node) {
      return node ? node.key : null
    }

    function eventListener(event) {
      var ovto_ev = #{Native(`event`)}
      return event.currentTarget.events[event.type](ovto_ev)
    }

    function updateAttribute(element, name, value, oldValue, isSvg) {
      if (name === "key") {
      } else if (name === "style") {
        for (var i in clone(oldValue, value)) {
          var style = value == null || value[i] == null ? "" : value[i]
          if (i[0] === "-") {
            element[name].setProperty(i, style)
          } else {
            element[name][i] = style
          }
        }
      } else {
        if (name[0] === "o" && name[1] === "n") {
          name = name.slice(2)

          if (element.events) {
            if (!oldValue) oldValue = element.events[name]
          } else {
            element.events = {}
          }

          element.events[name] = value

          if (value) {
            if (!oldValue) {
              element.addEventListener(name, eventListener)
            }
          } else {
            element.removeEventListener(name, eventListener)
          }
        } else if (name in element && name !== "list" && !isSvg) {
          element[name] = value == null ? "" : value
        } else if (value != null && value !== false) {
          element.setAttribute(name, value)
        }

        if (value == null || value === false) {
          element.removeAttribute(name)
        }
      }
    }

    function createElement(node, isSvg) {
      var element =
        typeof node === "string" || typeof node === "number"
          ? document.createTextNode(node)
          : (isSvg = isSvg || node.nodeName === "svg")
            ? document.createElementNS(
                "http://www.w3.org/2000/svg",
                node.nodeName
              )
            : document.createElement(node.nodeName)

      var attributes = node.attributes
      if (attributes) {
        if (attributes.oncreate) {
          lifecycle.push(function() {
            attributes.oncreate(element)
          })
        }
        for (var i = 0; i < node.children.length; i++) {
          element.appendChild(
            createElement(
              (node.children[i] = resolveNode(node.children[i])),
              isSvg
            )
          )
        }

        for (var name in attributes) {
          updateAttribute(element, name, attributes[name], null, isSvg)
        }
      }

      return element
    }

    function updateElement(element, oldAttributes, attributes, isSvg) {
      for (var name in clone(oldAttributes, attributes)) {
        if (
          attributes[name] !==
          (name === "value" || name === "checked"
            ? element[name]
            : oldAttributes[name])
        ) {
          updateAttribute(
            element,
            name,
            attributes[name],
            oldAttributes[name],
            isSvg
          )
        }
      }

      var cb = isRecycling ? attributes.oncreate : attributes.onupdate
      if (cb) {
        lifecycle.push(function() {
          cb(element, oldAttributes)
        })
      }
    }

    function removeChildren(element, node) {
      var attributes = node.attributes
      if (attributes) {
        for (var i = 0; i < node.children.length; i++) {
          removeChildren(element.childNodes[i], node.children[i])
        }

        if (attributes.ondestroy) {
          attributes.ondestroy(element)
        }
      }
      return element
    }

    function removeElement(parent, element, node) {
      function done() {
        parent.removeChild(removeChildren(element, node))
      }

      var cb = node.attributes && node.attributes.onremove
      if (cb) {
        cb(element, done)
      } else {
        done()
      }
    }

    function patch(parent, element, oldNode, node, isSvg) {
      if (node === oldNode) {
      } else if (oldNode == null || oldNode.nodeName !== node.nodeName) {
        var newElement = createElement(node, isSvg)
        parent.insertBefore(newElement, element)

        if (oldNode != null) {
          removeElement(parent, element, oldNode)
        }

        element = newElement
      } else if (oldNode.nodeName == null) {
        element.nodeValue = node
      } else {
        updateElement(
          element,
          oldNode.attributes,
          node.attributes,
          (isSvg = isSvg || node.nodeName === "svg")
        )

        var oldKeyed = {}
        var newKeyed = {}
        var oldElements = []
        var oldChildren = oldNode.children
        var children = node.children

        for (var i = 0; i < oldChildren.length; i++) {
          oldElements[i] = element.childNodes[i]

          var oldKey = getKey(oldChildren[i])
          if (oldKey != null) {
            oldKeyed[oldKey] = [oldElements[i], oldChildren[i]]
          }
        }

        var i = 0
        var k = 0

        while (k < children.length) {
          var oldKey = getKey(oldChildren[i])
          var newKey = getKey((children[k] = resolveNode(children[k])))

          if (newKeyed[oldKey]) {
            i++
            continue
          }

          if (newKey != null && newKey === getKey(oldChildren[i + 1])) {
            if (oldKey == null) {
              removeElement(element, oldElements[i], oldChildren[i])
            }
            i++
            continue
          }

          if (newKey == null || isRecycling) {
            if (oldKey == null) {
              patch(element, oldElements[i], oldChildren[i], children[k], isSvg)
              k++
            }
            i++
          } else {
            var keyedNode = oldKeyed[newKey] || []

            if (oldKey === newKey) {
              patch(element, keyedNode[0], keyedNode[1], children[k], isSvg)
              i++
            } else if (keyedNode[0]) {
              patch(
                element,
                element.insertBefore(keyedNode[0], oldElements[i]),
                keyedNode[1],
                children[k],
                isSvg
              )
            } else {
              patch(element, oldElements[i], null, children[k], isSvg)
            }

            newKeyed[newKey] = children[k]
            k++
          }
        }

        while (i < oldChildren.length) {
          if (getKey(oldChildren[i]) == null) {
            removeElement(element, oldElements[i], oldChildren[i])
          }
          i++
        }

        for (var i in oldKeyed) {
          if (!newKeyed[i]) {
            removeElement(element, oldKeyed[i][0], oldKeyed[i][1])
          }
        }
      }
      return element
    }
  };
}
