/* */ 
(function(Buffer) {
  var fs = require('fs');
  var path = require('path');
  var common = require('./common');
  var os = require('os');
  common.register('cp', _cp, {
    cmdOptions: {
      'f': '!no_force',
      'n': 'no_force',
      'u': 'update',
      'R': 'recursive',
      'r': 'recursive',
      'L': 'followsymlink',
      'P': 'noFollowsymlink'
    },
    wrapOutput: false
  });
  function copyFileSync(srcFile, destFile, options) {
    if (!fs.existsSync(srcFile)) {
      common.error('copyFileSync: no such file or directory: ' + srcFile);
    }
    try {
      if (options.update && fs.statSync(srcFile).mtime < fs.statSync(destFile).mtime) {
        return;
      }
    } catch (e) {}
    if (fs.lstatSync(srcFile).isSymbolicLink() && !options.followsymlink) {
      try {
        fs.lstatSync(destFile);
        common.unlinkSync(destFile);
      } catch (e) {}
      var symlinkFull = fs.readlinkSync(srcFile);
      fs.symlinkSync(symlinkFull, destFile, os.platform() === 'win32' ? 'junction' : null);
    } else {
      var BUF_LENGTH = 64 * 1024;
      var buf = new Buffer(BUF_LENGTH);
      var bytesRead = BUF_LENGTH;
      var pos = 0;
      var fdr = null;
      var fdw = null;
      try {
        fdr = fs.openSync(srcFile, 'r');
      } catch (e) {
        common.error('copyFileSync: could not read src file (' + srcFile + ')');
      }
      try {
        fdw = fs.openSync(destFile, 'w');
      } catch (e) {
        common.error('copyFileSync: could not write to dest file (code=' + e.code + '):' + destFile);
      }
      while (bytesRead === BUF_LENGTH) {
        bytesRead = fs.readSync(fdr, buf, 0, BUF_LENGTH, pos);
        fs.writeSync(fdw, buf, 0, bytesRead);
        pos += bytesRead;
      }
      fs.closeSync(fdr);
      fs.closeSync(fdw);
      fs.chmodSync(destFile, fs.statSync(srcFile).mode);
    }
  }
  function cpdirSyncRecursive(sourceDir, destDir, currentDepth, opts) {
    if (!opts)
      opts = {};
    if (currentDepth >= common.config.maxdepth)
      return;
    currentDepth++;
    try {
      var checkDir = fs.statSync(sourceDir);
      fs.mkdirSync(destDir, checkDir.mode);
    } catch (e) {
      if (e.code !== 'EEXIST')
        throw e;
    }
    var files = fs.readdirSync(sourceDir);
    for (var i = 0; i < files.length; i++) {
      var srcFile = sourceDir + '/' + files[i];
      var destFile = destDir + '/' + files[i];
      var srcFileStat = fs.lstatSync(srcFile);
      var symlinkFull;
      if (opts.followsymlink) {
        if (cpcheckcycle(sourceDir, srcFile)) {
          console.error('Cycle link found.');
          symlinkFull = fs.readlinkSync(srcFile);
          fs.symlinkSync(symlinkFull, destFile, os.platform() === 'win32' ? 'junction' : null);
          continue;
        }
      }
      if (srcFileStat.isDirectory()) {
        cpdirSyncRecursive(srcFile, destFile, currentDepth, opts);
      } else if (srcFileStat.isSymbolicLink() && !opts.followsymlink) {
        symlinkFull = fs.readlinkSync(srcFile);
        try {
          fs.lstatSync(destFile);
          common.unlinkSync(destFile);
        } catch (e) {}
        fs.symlinkSync(symlinkFull, destFile, os.platform() === 'win32' ? 'junction' : null);
      } else if (srcFileStat.isSymbolicLink() && opts.followsymlink) {
        srcFileStat = fs.statSync(srcFile);
        if (srcFileStat.isDirectory()) {
          cpdirSyncRecursive(srcFile, destFile, currentDepth, opts);
        } else {
          copyFileSync(srcFile, destFile, opts);
        }
      } else {
        if (fs.existsSync(destFile) && opts.no_force) {
          common.log('skipping existing file: ' + files[i]);
        } else {
          copyFileSync(srcFile, destFile, opts);
        }
      }
    }
  }
  function cpcheckcycle(sourceDir, srcFile) {
    var srcFileStat = fs.lstatSync(srcFile);
    if (srcFileStat.isSymbolicLink()) {
      var cyclecheck = fs.statSync(srcFile);
      if (cyclecheck.isDirectory()) {
        var sourcerealpath = fs.realpathSync(sourceDir);
        var symlinkrealpath = fs.realpathSync(srcFile);
        var re = new RegExp(symlinkrealpath);
        if (re.test(sourcerealpath)) {
          return true;
        }
      }
    }
    return false;
  }
  function _cp(options, sources, dest) {
    if (options.followsymlink) {
      options.noFollowsymlink = false;
    }
    if (!options.recursive && !options.noFollowsymlink) {
      options.followsymlink = true;
    }
    if (arguments.length < 3) {
      common.error('missing <source> and/or <dest>');
    } else {
      sources = [].slice.call(arguments, 1, arguments.length - 1);
      dest = arguments[arguments.length - 1];
    }
    var destExists = fs.existsSync(dest);
    var destStat = destExists && fs.statSync(dest);
    if ((!destExists || !destStat.isDirectory()) && sources.length > 1) {
      common.error('dest is not a directory (too many sources)');
    }
    if (destExists && destStat.isFile() && options.no_force) {
      return new common.ShellString('', '', 0);
    }
    sources.forEach(function(src) {
      if (!fs.existsSync(src)) {
        common.error('no such file or directory: ' + src, {continue: true});
        return;
      }
      var srcStat = fs.statSync(src);
      if (!options.noFollowsymlink && srcStat.isDirectory()) {
        if (!options.recursive) {
          common.error("omitting directory '" + src + "'", {continue: true});
        } else {
          var newDest = (destStat && destStat.isDirectory()) ? path.join(dest, path.basename(src)) : dest;
          try {
            fs.statSync(path.dirname(dest));
            cpdirSyncRecursive(src, newDest, 0, {
              no_force: options.no_force,
              followsymlink: options.followsymlink
            });
          } catch (e) {
            common.error("cannot create directory '" + dest + "': No such file or directory");
          }
        }
      } else {
        var thisDest = dest;
        if (destStat && destStat.isDirectory()) {
          thisDest = path.normalize(dest + '/' + path.basename(src));
        }
        if (fs.existsSync(thisDest) && options.no_force) {
          return;
        }
        copyFileSync(src, thisDest, options);
      }
    });
    return new common.ShellString('', common.state.error, common.state.errorCode);
  }
  module.exports = _cp;
})(require('buffer').Buffer);
