/* */ 
describe('Tmpl Tests', function() {
  expect = require('expect.js');
  tmpl = require('../dist/tmpl').tmpl;
  brackets = require('../dist/tmpl').brackets;
  require('./specs/core.specs');
  require('./specs/brackets.specs');
});
