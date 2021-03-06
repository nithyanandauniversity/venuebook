/* */ 
(function(process) {
  var path = require('path');
  var common = require('./common');
  common.register('pwd', _pwd, {allowGlobbing: false});
  function _pwd() {
    var pwd = path.resolve(process.cwd());
    return pwd;
  }
  module.exports = _pwd;
})(require('process'));
