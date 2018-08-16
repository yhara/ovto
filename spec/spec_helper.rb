require 'ovto'

def js_obj_to_hash(obj)
  JSON.parse(`JSON.stringify(obj)`)
end
