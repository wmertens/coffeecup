var h, text, yield, __cc;

__cc = {
  buffer: ""
};

text = function(txt) {
  __cc.buffer += txt;
  return;
};

h = function(txt) {
  var t;
  t = typeof txt === "string" || txt instanceof String ? t : t.toString();
  return t.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
};

yield = function(f) {
  var old_buffer, temp_buffer;
  old_buffer = __cc.buffer;
  __cc.buffer = "";
  f();
  temp_buffer = __cc.buffer;
  __cc.buffer = old_buffer;
  return temp_buffer;
};
