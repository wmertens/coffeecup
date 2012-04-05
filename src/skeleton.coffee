__cc = buffer: ""

text = (txt) ->
  __cc.buffer += txt
  undefined

h = (txt) ->
  t = if typeof txt is "string" or txt instanceof String then t else t.toString()
  t.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;")

yield = (f) ->
  old_buffer = __cc.buffer
  __cc.buffer = ""
  f()
  temp_buffer = __cc.buffer
  __cc.buffer = old_buffer
  return temp_buffer
