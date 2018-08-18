require 'promise'
require 'native'
require 'json'

module Ovto
  # Wrapper for the fetch API
  # The server must respond a json text.
  #
  # Example:
  #   Ovto.fetch('/api/new_task', 'POST', {title: "do something"}){|json_data|
  #     p json_data
  #   }.fail{|e|  # Network error, 404 Not Found, JSON parse error, etc.
  #     p e
  #   }
  def self.fetch(url, method='GET', data=nil)
    init = `{method: #{method}}`
    if method != 'GET'
      %x{
        var headers = {'Content-Type': 'application/json'};
        var metaTag = document.querySelector('meta[name=csrf-token]');
        if (metaTag) headers['X-CSRF-Token'] = metaTag.content;

        init['credentials'] = 'same-origin'; // Enable sending cookie (for CookieStore of Rails)
        init['headers'] = headers;
        init['body'] = #{data.to_json};
      }
    end
    return _do_fetch(url, init)
  end

  # Create an Opal Promise to call fetch API
  def self._do_fetch(url, init)
    promise = Promise.new
    text = error = nil
    %x{
      fetch(url, init).then(response => {
        if (response.ok) {
          return response.text();
        }
        else {
          throw response;
        }
      }).then(text =>
        #{promise.resolve(JSON.parse(text))}
      ).catch(error =>
        #{promise.reject(error)}
      );
    }
    return promise
  end
end
