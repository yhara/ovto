if RUBY_ENGINE == 'opal'
  require 'console'; def console; $console; end
  require_relative 'ovto/actions'
  require_relative 'ovto/app'
  require_relative 'ovto/component'
  require_relative 'ovto/pure_component'
  require_relative 'ovto/fetch'
  require_relative 'ovto/runtime'
  require_relative 'ovto/state'
  require_relative 'ovto/version'
  require_relative 'ovto/wired_actions'
  require_relative 'ovto/wired_action_set'
  require_relative 'ovto/middleware'
else
  require 'ovto/version'
  require 'opal'; Opal.append_path(__dir__)
end

module Ovto
  # Debug mode
  @debug_trace = false
  def self.debug_trace; @debug_trace; end
  def self.debug_trace=(bool); @debug_trace = bool; end
  def self.debug_trace_log(msg)
    console.log("Ovto: "+msg) if @debug_trace
  end

  # JS-object-safe inspect
  def self.inspect(obj)
    if `obj.$inspect`
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
    raise ex if `typeof document === 'undefined'`  # On unit tests

    div = `document.getElementById('ovto-debug')`
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
