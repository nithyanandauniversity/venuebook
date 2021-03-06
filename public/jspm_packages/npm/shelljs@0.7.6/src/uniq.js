/* */ 
var common = require('./common');
var fs = require('fs');
function lpad(c, str) {
  var res = '' + str;
  if (res.length < c) {
    res = Array((c - res.length) + 1).join(' ') + res;
  }
  return res;
}
common.register('uniq', _uniq, {
  canReceivePipe: true,
  cmdOptions: {
    'i': 'ignoreCase',
    'c': 'count',
    'd': 'duplicates'
  }
});
function _uniq(options, input, output) {
  var pipe = common.readFromPipe();
  if (!input && !pipe)
    common.error('no input given');
  var lines = (input ? fs.readFileSync(input, 'utf8') : pipe).trimRight().split(/\r*\n/);
  var compare = function(a, b) {
    return options.ignoreCase ? a.toLocaleLowerCase().localeCompare(b.toLocaleLowerCase()) : a.localeCompare(b);
  };
  var uniqed = lines.reduceRight(function(res, e) {
    if (res.length === 0) {
      return [{
        count: 1,
        ln: e
      }];
    } else if (compare(res[0].ln, e) === 0) {
      return [{
        count: res[0].count + 1,
        ln: e
      }].concat(res.slice(1));
    } else {
      return [{
        count: 1,
        ln: e
      }].concat(res);
    }
  }, []).filter(function(obj) {
    return options.duplicates ? obj.count > 1 : true;
  }).map(function(obj) {
    return (options.count ? (lpad(7, obj.count) + ' ') : '') + obj.ln;
  }).join('\n') + '\n';
  if (output) {
    (new common.ShellString(uniqed)).to(output);
    return '';
  } else {
    return uniqed;
  }
}
module.exports = _uniq;
