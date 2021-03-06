/* */ 
var common = require('./common');
var fs = require('fs');
common.register('grep', _grep, {
  globStart: 2,
  canReceivePipe: true,
  cmdOptions: {
    'v': 'inverse',
    'l': 'nameOnly'
  }
});
function _grep(options, regex, files) {
  var pipe = common.readFromPipe();
  if (!files && !pipe)
    common.error('no paths given', 2);
  files = [].slice.call(arguments, 2);
  if (pipe) {
    files.unshift('-');
  }
  var grep = [];
  files.forEach(function(file) {
    if (!fs.existsSync(file) && file !== '-') {
      common.error('no such file or directory: ' + file, 2, {continue: true});
      return;
    }
    var contents = file === '-' ? pipe : fs.readFileSync(file, 'utf8');
    var lines = contents.split(/\r*\n/);
    if (options.nameOnly) {
      if (contents.match(regex)) {
        grep.push(file);
      }
    } else {
      lines.forEach(function(line) {
        var matched = line.match(regex);
        if ((options.inverse && !matched) || (!options.inverse && matched)) {
          grep.push(line);
        }
      });
    }
  });
  return grep.join('\n') + '\n';
}
module.exports = _grep;
