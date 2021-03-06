/* */ 
var common = require('./common');
var fs = require('fs');
common.register('tail', _tail, {
  canReceivePipe: true,
  cmdOptions: {'n': 'numLines'}
});
function _tail(options, files) {
  var tail = [];
  var pipe = common.readFromPipe();
  if (!files && !pipe)
    common.error('no paths given');
  var idx = 1;
  if (options.numLines === true) {
    idx = 2;
    options.numLines = Number(arguments[1]);
  } else if (options.numLines === false) {
    options.numLines = 10;
  }
  options.numLines = -1 * Math.abs(options.numLines);
  files = [].slice.call(arguments, idx);
  if (pipe) {
    files.unshift('-');
  }
  var shouldAppendNewline = false;
  files.forEach(function(file) {
    if (!fs.existsSync(file) && file !== '-') {
      common.error('no such file or directory: ' + file, {continue: true});
      return;
    }
    var contents = file === '-' ? pipe : fs.readFileSync(file, 'utf8');
    var lines = contents.split('\n');
    if (lines[lines.length - 1] === '') {
      lines.pop();
      shouldAppendNewline = true;
    } else {
      shouldAppendNewline = false;
    }
    tail = tail.concat(lines.slice(options.numLines));
  });
  if (shouldAppendNewline) {
    tail.push('');
  }
  return tail.join('\n');
}
module.exports = _tail;
