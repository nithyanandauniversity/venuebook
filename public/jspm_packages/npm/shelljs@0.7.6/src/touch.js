/* */ 
var common = require('./common');
var fs = require('fs');
common.register('touch', _touch, {cmdOptions: {
    'a': 'atime_only',
    'c': 'no_create',
    'd': 'date',
    'm': 'mtime_only',
    'r': 'reference'
  }});
function _touch(opts, files) {
  if (!files) {
    common.error('no files given');
  } else if (typeof files === 'string') {
    files = [].slice.call(arguments, 1);
  } else {
    common.error('file arg should be a string file path or an Array of string file paths');
  }
  files.forEach(function(f) {
    touchFile(opts, f);
  });
  return '';
}
function touchFile(opts, file) {
  var stat = tryStatFile(file);
  if (stat && stat.isDirectory()) {
    return;
  }
  if (!stat && opts.no_create) {
    return;
  }
  fs.closeSync(fs.openSync(file, 'a'));
  var now = new Date();
  var mtime = opts.date || now;
  var atime = opts.date || now;
  if (opts.reference) {
    var refStat = tryStatFile(opts.reference);
    if (!refStat) {
      common.error('failed to get attributess of ' + opts.reference);
    }
    mtime = refStat.mtime;
    atime = refStat.atime;
  } else if (opts.date) {
    mtime = opts.date;
    atime = opts.date;
  }
  if (opts.atime_only && opts.mtime_only) {} else if (opts.atime_only) {
    mtime = stat.mtime;
  } else if (opts.mtime_only) {
    atime = stat.atime;
  }
  fs.utimesSync(file, atime, mtime);
}
module.exports = _touch;
function tryStatFile(filePath) {
  try {
    return fs.statSync(filePath);
  } catch (e) {
    return null;
  }
}
