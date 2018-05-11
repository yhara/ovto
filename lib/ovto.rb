if RUBY_ENGINE == 'opal'
  require_relative 'ovto/app'
  require_relative 'ovto/component'
  require_relative 'ovto/runtime'
  require_relative 'ovto/state'
  require_relative 'ovto/version'
  require_relative 'ovto/wired_actions'
else
  require 'ovto/version'
  require 'opal'; Opal.append_path("#{__dir__}/..")
end

module Ovto
  # JS-object-safe inspect
  def self.inspect(obj)
    if `#{obj}.$$id`
      obj.inspect
    else
      `JSON.stringify(#{obj}) || "undefined"`
    end
  end

  # Call block. If an exception is raised and there is a tag with `id='ovto-debug'`,
  # describe the error in that tag
  def self.log_error(&block)
    return block.call
  rescue Exception => ex
    div = `document.getElementById('ovto-debug')`
    `console.log(document.getElementById('ovto-debug'))`
    if `div && !ex.OvtoPrinted`
      %x{
        div.textContent = "ERROR: " + #{ex.class.name};
        var ul = document.createElement('ul');
        // Note: ex.backtrace may be an Array or a String
        #{Array(ex.backtrace)}.forEach(function(line){
          var li = document.createElement('li');
          li.textContent = line;
          ul.appendChild(li);
        });
        div.appendChild(ul);
        ex.OvtoPrinted = true;
      }
    end
    raise ex
  end
end
