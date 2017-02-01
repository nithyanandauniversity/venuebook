/* */ 
var tape = require('tape');
var gen = require('../generate-object-property@1.2.0.json!systemjs-json');
tape('valid', function(t) {
  t.same(gen('a', 'b'), 'a.b');
  t.end();
});
tape('invalid', function(t) {
  t.same(gen('a', '-b'), 'a["-b"]');
  t.end();
});
