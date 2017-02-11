/* */ 
(function(process) {
  var common = require('./src/common');
  require('./commands.json!systemjs-json').forEach(function(command) {
    require('./src/' + command);
  });
  exports.exit = process.exit;
  exports.error = require('./src/error');
  exports.ShellString = common.ShellString;
  exports.env = process.env;
  exports.config = common.config;
})(require('process'));
