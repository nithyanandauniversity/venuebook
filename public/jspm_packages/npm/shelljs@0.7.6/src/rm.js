/* */ 
(function(process) {
  var common = require('./common');
  var fs = require('fs');
  common.register('rm', _rm, {cmdOptions: {
      'f': 'force',
      'r': 'recursive',
      'R': 'recursive'
    }});
  function rmdirSyncRecursive(dir, force) {
    var files;
    files = fs.readdirSync(dir);
    for (var i = 0; i < files.length; i++) {
      var file = dir + '/' + files[i];
      var currFile = fs.lstatSync(file);
      if (currFile.isDirectory()) {
        rmdirSyncRecursive(file, force);
      } else {
        if (force || isWriteable(file)) {
          try {
            common.unlinkSync(file);
          } catch (e) {
            common.error('could not remove file (code ' + e.code + '): ' + file, {continue: true});
          }
        }
      }
    }
    var result;
    try {
      var start = Date.now();
      for (; ; ) {
        try {
          result = fs.rmdirSync(dir);
          if (fs.existsSync(dir))
            throw {code: 'EAGAIN'};
          break;
        } catch (er) {
          if (process.platform === 'win32' && (er.code === 'ENOTEMPTY' || er.code === 'EBUSY' || er.code === 'EPERM' || er.code === 'EAGAIN')) {
            if (Date.now() - start > 1000)
              throw er;
          } else if (er.code === 'ENOENT') {
            break;
          } else {
            throw er;
          }
        }
      }
    } catch (e) {
      common.error('could not remove directory (code ' + e.code + '): ' + dir, {continue: true});
    }
    return result;
  }
  function isWriteable(file) {
    var writePermission = true;
    try {
      var __fd = fs.openSync(file, 'a');
      fs.closeSync(__fd);
    } catch (e) {
      writePermission = false;
    }
    return writePermission;
  }
  function _rm(options, files) {
    if (!files)
      common.error('no paths given');
    files = [].slice.call(arguments, 1);
    files.forEach(function(file) {
      var stats;
      try {
        stats = fs.lstatSync(file);
      } catch (e) {
        if (!options.force) {
          common.error('no such file or directory: ' + file, {continue: true});
        }
        return;
      }
      if (stats.isFile()) {
        if (options.force || isWriteable(file)) {
          common.unlinkSync(file);
        } else {
          common.error('permission denied: ' + file, {continue: true});
        }
      } else if (stats.isDirectory()) {
        if (options.recursive) {
          rmdirSyncRecursive(file, options.force);
        } else {
          common.error('path is a directory', {continue: true});
        }
      } else if (stats.isSymbolicLink()) {
        common.unlinkSync(file);
      }
    });
    return '';
  }
  module.exports = _rm;
})(require('process'));
