/* */ 
(function(process) {
  var common = require('./common');
  var _tempDir = require('./tempdir');
  var _pwd = require('./pwd');
  var path = require('path');
  var fs = require('fs');
  var child = require('child_process');
  var DEFAULT_MAXBUFFER_SIZE = 20 * 1024 * 1024;
  common.register('exec', _exec, {
    unix: false,
    canReceivePipe: true,
    wrapOutput: false
  });
  function execSync(cmd, opts, pipe) {
    if (!common.config.execPath) {
      common.error('Unable to find a path to the node binary. Please manually set config.execPath');
    }
    var tempDir = _tempDir();
    var stdoutFile = path.resolve(tempDir + '/' + common.randomFileName());
    var stderrFile = path.resolve(tempDir + '/' + common.randomFileName());
    var codeFile = path.resolve(tempDir + '/' + common.randomFileName());
    var scriptFile = path.resolve(tempDir + '/' + common.randomFileName());
    var sleepFile = path.resolve(tempDir + '/' + common.randomFileName());
    opts = common.extend({
      silent: common.config.silent,
      cwd: _pwd().toString(),
      env: process.env,
      maxBuffer: DEFAULT_MAXBUFFER_SIZE
    }, opts);
    var previousStdoutContent = '';
    var previousStderrContent = '';
    function updateStream(streamFile) {
      if (opts.silent || !fs.existsSync(streamFile)) {
        return;
      }
      var previousStreamContent;
      var procStream;
      if (streamFile === stdoutFile) {
        previousStreamContent = previousStdoutContent;
        procStream = process.stdout;
      } else {
        previousStreamContent = previousStderrContent;
        procStream = process.stderr;
      }
      var streamContent = fs.readFileSync(streamFile, 'utf8');
      if (streamContent.length <= previousStreamContent.length) {
        return;
      }
      procStream.write(streamContent.substr(previousStreamContent.length));
      previousStreamContent = streamContent;
    }
    if (fs.existsSync(scriptFile))
      common.unlinkSync(scriptFile);
    if (fs.existsSync(stdoutFile))
      common.unlinkSync(stdoutFile);
    if (fs.existsSync(stderrFile))
      common.unlinkSync(stderrFile);
    if (fs.existsSync(codeFile))
      common.unlinkSync(codeFile);
    var execCommand = JSON.stringify(common.config.execPath) + ' ' + JSON.stringify(scriptFile);
    var script;
    opts.cwd = path.resolve(opts.cwd);
    var optString = JSON.stringify(opts);
    if (typeof child.execSync === 'function') {
      script = ["var child = require('child_process')", "  , fs = require('fs');", 'var childProcess = child.exec(' + JSON.stringify(cmd) + ', ' + optString + ', function(err) {', '  var fname = ' + JSON.stringify(codeFile) + ';', '  if (!err) {', '    fs.writeFileSync(fname, "0");', '  } else if (err.code === undefined) {', '    fs.writeFileSync(fname, "1");', '  } else {', '    fs.writeFileSync(fname, err.code.toString());', '  }', '});', 'var stdoutStream = fs.createWriteStream(' + JSON.stringify(stdoutFile) + ');', 'var stderrStream = fs.createWriteStream(' + JSON.stringify(stderrFile) + ');', 'childProcess.stdout.pipe(stdoutStream, {end: false});', 'childProcess.stderr.pipe(stderrStream, {end: false});', 'childProcess.stdout.pipe(process.stdout);', 'childProcess.stderr.pipe(process.stderr);'].join('\n') + (pipe ? '\nchildProcess.stdin.end(' + JSON.stringify(pipe) + ');\n' : '\n') + ['var stdoutEnded = false, stderrEnded = false;', 'function tryClosingStdout(){ if(stdoutEnded){ stdoutStream.end(); } }', 'function tryClosingStderr(){ if(stderrEnded){ stderrStream.end(); } }', "childProcess.stdout.on('end', function(){ stdoutEnded = true; tryClosingStdout(); });", "childProcess.stderr.on('end', function(){ stderrEnded = true; tryClosingStderr(); });"].join('\n');
      fs.writeFileSync(scriptFile, script);
      if (opts.silent) {
        opts.stdio = 'ignore';
      } else {
        opts.stdio = [0, 1, 2];
      }
      try {
        child.execSync(execCommand, opts);
      } catch (e) {
        try {
          common.unlinkSync(scriptFile);
        } catch (e2) {}
        try {
          common.unlinkSync(stdoutFile);
        } catch (e2) {}
        try {
          common.unlinkSync(stderrFile);
        } catch (e2) {}
        try {
          common.unlinkSync(codeFile);
        } catch (e2) {}
        throw e;
      }
    } else {
      cmd += ' > ' + stdoutFile + ' 2> ' + stderrFile;
      script = ["var child = require('child_process')", "  , fs = require('fs');", 'var childProcess = child.exec(' + JSON.stringify(cmd) + ', ' + optString + ', function(err) {', '  var fname = ' + JSON.stringify(codeFile) + ';', '  if (!err) {', '    fs.writeFileSync(fname, "0");', '  } else if (err.code === undefined) {', '    fs.writeFileSync(fname, "1");', '  } else {', '    fs.writeFileSync(fname, err.code.toString());', '  }', '});'].join('\n') + (pipe ? '\nchildProcess.stdin.end(' + JSON.stringify(pipe) + ');\n' : '\n');
      fs.writeFileSync(scriptFile, script);
      child.exec(execCommand, opts);
      while (!fs.existsSync(codeFile)) {
        updateStream(stdoutFile);
        fs.writeFileSync(sleepFile, 'a');
      }
      while (!fs.existsSync(stdoutFile)) {
        updateStream(stdoutFile);
        fs.writeFileSync(sleepFile, 'a');
      }
      while (!fs.existsSync(stderrFile)) {
        updateStream(stderrFile);
        fs.writeFileSync(sleepFile, 'a');
      }
      try {
        common.unlinkSync(sleepFile);
      } catch (e) {}
    }
    var code = parseInt('', 10);
    while (isNaN(code)) {
      code = parseInt(fs.readFileSync(codeFile, 'utf8'), 10);
    }
    var stdout = fs.readFileSync(stdoutFile, 'utf8');
    var stderr = fs.readFileSync(stderrFile, 'utf8');
    try {
      common.unlinkSync(scriptFile);
    } catch (e) {}
    try {
      common.unlinkSync(stdoutFile);
    } catch (e) {}
    try {
      common.unlinkSync(stderrFile);
    } catch (e) {}
    try {
      common.unlinkSync(codeFile);
    } catch (e) {}
    if (code !== 0) {
      common.error('', code, {continue: true});
    }
    var obj = common.ShellString(stdout, stderr, code);
    return obj;
  }
  function execAsync(cmd, opts, pipe, callback) {
    var stdout = '';
    var stderr = '';
    opts = common.extend({
      silent: common.config.silent,
      cwd: _pwd().toString(),
      env: process.env,
      maxBuffer: DEFAULT_MAXBUFFER_SIZE
    }, opts);
    var c = child.exec(cmd, opts, function(err) {
      if (callback) {
        if (!err) {
          callback(0, stdout, stderr);
        } else if (err.code === undefined) {
          callback(1, stdout, stderr);
        } else {
          callback(err.code, stdout, stderr);
        }
      }
    });
    if (pipe)
      c.stdin.end(pipe);
    c.stdout.on('data', function(data) {
      stdout += data;
      if (!opts.silent)
        process.stdout.write(data);
    });
    c.stderr.on('data', function(data) {
      stderr += data;
      if (!opts.silent)
        process.stderr.write(data);
    });
    return c;
  }
  function _exec(command, options, callback) {
    options = options || {};
    if (!command)
      common.error('must specify command');
    var pipe = common.readFromPipe();
    if (typeof options === 'function') {
      callback = options;
      options = {async: true};
    }
    if (typeof options === 'object' && typeof callback === 'function') {
      options.async = true;
    }
    options = common.extend({
      silent: common.config.silent,
      async: false
    }, options);
    try {
      if (options.async) {
        return execAsync(command, options, pipe, callback);
      } else {
        return execSync(command, options, pipe);
      }
    } catch (e) {
      common.error('internal error');
    }
  }
  module.exports = _exec;
})(require('process'));
