/* */ 
(function(Buffer, process) {
  'use strict';
  var brackets = require('./brackets');
  var parsers = require('./parsers');
  var safeRegex = require('./safe-regex');
  var path = require('path');
  var extend = require('./parsers/_utils').mixobj;
  var S_LINESTR = /"[^"\n\\]*(?:\\[\S\s][^"\n\\]*)*"|'[^'\n\\]*(?:\\[\S\s][^'\n\\]*)*'/.source;
  var S_STRINGS = brackets.R_STRINGS.source;
  var HTML_ATTRS = / *([-\w:\xA0-\xFF]+) ?(?:= ?('[^']*'|"[^"]*"|\S+))?/g;
  var HTML_COMMS = RegExp(/<!--(?!>)[\S\s]*?-->/.source + '|' + S_LINESTR, 'g');
  var HTML_TAGS = /<(-?[A-Za-z][-\w\xA0-\xFF]*)(?:\s+([^"'\/>]*(?:(?:"[^"]*"|'[^']*'|\/[^>])[^'"\/>]*)*)|\s*)(\/?)>/g;
  var HTML_PACK = />[ \t]+<(-?[A-Za-z]|\/[-A-Za-z])/g;
  var RIOT_ATTRS = ['style', 'src', 'd', 'value'];
  var VOID_TAGS = /^(?:input|img|br|wbr|hr|area|base|col|embed|keygen|link|meta|param|source|track)$/;
  var PRE_TAGS = /<pre(?:\s+(?:[^">]*|"[^"]*")*)?>([\S\s]+?)<\/pre\s*>/gi;
  var SPEC_TYPES = /^"(?:number|date(?:time)?|time|month|email|color)\b/i;
  var IMPORT_STATEMENT = /^\s*import(?:(?:\s|[^\s'"])*)['|"].*\n?/gm;
  var TRIM_TRAIL = /[ \t]+$/gm;
  var RE_HASEXPR = safeRegex(/@#\d/, 'x01'),
      RE_REPEXPR = safeRegex(/@#(\d+)/g, 'x01'),
      CH_IDEXPR = '\x01#',
      CH_DQCODE = '\u2057',
      DQ = '"',
      SQ = "'";
  function cleanSource(src) {
    var mm,
        re = HTML_COMMS;
    if (~src.indexOf('\r')) {
      src = src.replace(/\r\n?/g, '\n');
    }
    re.lastIndex = 0;
    while ((mm = re.exec(src))) {
      if (mm[0][0] === '<') {
        src = RegExp.leftContext + RegExp.rightContext;
        re.lastIndex = mm[3] + 1;
      }
    }
    return src;
  }
  function parseAttribs(str, pcex) {
    var list = [],
        match,
        type,
        vexp;
    HTML_ATTRS.lastIndex = 0;
    str = str.replace(/\s+/g, ' ');
    while ((match = HTML_ATTRS.exec(str))) {
      var k = match[1].toLowerCase(),
          v = match[2];
      if (!v) {
        list.push(k);
      } else {
        if (v[0] !== DQ) {
          v = DQ + (v[0] === SQ ? v.slice(1, -1) : v) + DQ;
        }
        if (k === 'type' && SPEC_TYPES.test(v)) {
          type = v;
        } else {
          if (RE_HASEXPR.test(v)) {
            if (k === 'value')
              vexp = 1;
            if (~RIOT_ATTRS.indexOf(k))
              k = 'riot-' + k;
          }
          list.push(k + '=' + v);
        }
      }
    }
    if (type) {
      if (vexp)
        type = DQ + pcex._bp[0] + SQ + type.slice(1, -1) + SQ + pcex._bp[1] + DQ;
      list.push('type=' + type);
    }
    return list.join(' ');
  }
  function splitHtml(html, opts, pcex) {
    var _bp = pcex._bp;
    if (html && _bp[4].test(html)) {
      var jsfn = opts.expr && (opts.parser || opts.type) ? _compileJS : 0,
          list = brackets.split(html, 0, _bp),
          expr;
      for (var i = 1; i < list.length; i += 2) {
        expr = list[i];
        if (expr[0] === '^') {
          expr = expr.slice(1);
        } else if (jsfn) {
          expr = jsfn(expr, opts).trim();
          if (expr.slice(-1) === ';')
            expr = expr.slice(0, -1);
        }
        list[i] = CH_IDEXPR + (pcex.push(expr) - 1) + _bp[1];
      }
      html = list.join('');
    }
    return html;
  }
  function restoreExpr(html, pcex) {
    if (pcex.length) {
      html = html.replace(RE_REPEXPR, function(_, d) {
        return pcex._bp[0] + pcex[d].trim().replace(/[\r\n]+/g, ' ').replace(/"/g, CH_DQCODE);
      });
    }
    return html;
  }
  function _compileHTML(html, opts, pcex) {
    if (!/\S/.test(html))
      return '';
    html = splitHtml(html, opts, pcex).replace(HTML_TAGS, function(_, name, attr, ends) {
      name = name.toLowerCase();
      ends = ends && !VOID_TAGS.test(name) ? '></' + name : '';
      if (attr)
        name += ' ' + parseAttribs(attr, pcex);
      return '<' + name + ends + '>';
    });
    if (!opts.whitespace) {
      var p = [];
      if (/<pre[\s>]/.test(html)) {
        html = html.replace(PRE_TAGS, function(q) {
          p.push(q);
          return '\u0002';
        });
      }
      html = html.trim().replace(/\s+/g, ' ');
      if (p.length)
        html = html.replace(/\u0002/g, function() {
          return p.shift();
        });
    }
    if (opts.compact)
      html = html.replace(HTML_PACK, '><$1');
    return restoreExpr(html, pcex).replace(TRIM_TRAIL, '');
  }
  function compileHTML(html, opts, pcex) {
    if (Array.isArray(opts)) {
      pcex = opts;
      opts = {};
    } else {
      if (!pcex)
        pcex = [];
      if (!opts)
        opts = {};
    }
    pcex._bp = brackets.array(opts.brackets);
    return _compileHTML(cleanSource(html), opts, pcex);
  }
  var JS_ES6SIGN = /^[ \t]*([$_A-Za-z][$\w]*)\s*\([^()]*\)\s*{/m;
  var JS_ES6END = RegExp('[{}]|' + brackets.S_QBLOCKS, 'g');
  var JS_COMMS = RegExp(brackets.R_MLCOMMS.source + '|//[^\r\n]*|' + brackets.S_QBLOCKS, 'g');
  function riotjs(js) {
    var parts = [],
        match,
        toes5,
        pos,
        name,
        RE = RegExp;
    if (~js.indexOf('/'))
      js = rmComms(js, JS_COMMS);
    while ((match = js.match(JS_ES6SIGN))) {
      parts.push(RE.leftContext);
      js = RE.rightContext;
      pos = skipBody(js, JS_ES6END);
      name = match[1];
      toes5 = !/^(?:if|while|for|switch|catch|function)$/.test(name);
      name = toes5 ? match[0].replace(name, 'this.' + name + ' = function') : match[0];
      parts.push(name, js.slice(0, pos));
      js = js.slice(pos);
      if (toes5 && !/^\s*.\s*bind\b/.test(js))
        parts.push('.bind(this)');
    }
    return parts.length ? parts.join('') + js : js;
    function rmComms(s, r, m) {
      r.lastIndex = 0;
      while ((m = r.exec(s))) {
        if (m[0][0] === '/' && !m[1] && !m[2]) {
          s = RE.leftContext + ' ' + RE.rightContext;
          r.lastIndex = m[3] + 1;
        }
      }
      return s;
    }
    function skipBody(s, r) {
      var m,
          i = 1;
      r.lastIndex = 0;
      while (i && (m = r.exec(s))) {
        if (m[0] === '{')
          ++i;
        else if (m[0] === '}')
          --i;
      }
      return i ? s.length : r.lastIndex;
    }
  }
  function _compileJS(js, opts, type, parserOpts, url) {
    if (!/\S/.test(js))
      return '';
    if (!type)
      type = opts.type;
    var parser = opts.parser || type && parsers._req('js.' + type, true) || riotjs;
    return parser(js, parserOpts, url).replace(/\r\n?/g, '\n').replace(TRIM_TRAIL, '');
  }
  function compileJS(js, opts, type, userOpts) {
    if (typeof opts === 'string') {
      userOpts = type;
      type = opts;
      opts = {};
    }
    if (type && typeof type === 'object') {
      userOpts = type;
      type = '';
    }
    if (!userOpts)
      userOpts = {};
    return _compileJS(js, opts || {}, type, userOpts.parserOptions, userOpts.url);
  }
  var CSS_SELECTOR = RegExp('([{}]|^)[; ]*((?:[^@ ;{}][^{}]*)?[^@ ;{}:] ?)(?={)|' + S_LINESTR, 'g');
  function scopedCSS(tag, css) {
    var scope = ':scope';
    return css.replace(CSS_SELECTOR, function(m, p1, p2) {
      if (!p2)
        return m;
      p2 = p2.replace(/[^,]+/g, function(sel) {
        var s = sel.trim();
        if (s.indexOf(tag) === 0) {
          return sel;
        }
        if (!s || s === 'from' || s === 'to' || s.slice(-1) === '%') {
          return sel;
        }
        if (s.indexOf(scope) < 0) {
          s = tag + ' ' + s + ',[data-is="' + tag + '"] ' + s;
        } else {
          s = s.replace(scope, tag) + ',' + s.replace(scope, '[data-is="' + tag + '"]');
        }
        return s;
      });
      return p1 ? p1 + ' ' + p2 : p2;
    });
  }
  function _compileCSS(css, tag, type, opts) {
    opts = opts || {};
    if (type) {
      if (type !== 'css') {
        var parser = parsers._req('css.' + type, true);
        css = parser(tag, css, opts.parserOpts || {}, opts.url);
      }
    }
    css = css.replace(brackets.R_MLCOMMS, '').replace(/\s+/g, ' ').trim();
    if (tag)
      css = scopedCSS(tag, css);
    return css;
  }
  function compileCSS(css, type, opts) {
    if (type && typeof type === 'object') {
      opts = type;
      type = '';
    } else if (!opts)
      opts = {};
    return _compileCSS(css, opts.tagName, type, opts);
  }
  var DEFER_ATTR = /\sdefer(?=\s|>|$)/i;
  var TYPE_ATTR = /\stype\s*=\s*(?:(['"])(.+?)\1|(\S+))/i;
  var MISC_ATTR = '\\s*=\\s*(' + S_STRINGS + '|{[^}]+}|\\S+)';
  var END_TAGS = /\/>\n|^<(?:\/?-?[A-Za-z][-\w\xA0-\xFF]*\s*|-?[A-Za-z][-\w\xA0-\xFF]*\s+[-\w:\xA0-\xFF][\S\s]*?)>\n/;
  function _q(s, r) {
    if (!s)
      return "''";
    s = SQ + s.replace(/\\/g, '\\\\').replace(/'/g, "\\'") + SQ;
    return r && ~s.indexOf('\n') ? s.replace(/\n/g, '\\n') : s;
  }
  function mktag(name, html, css, attr, js, imports, opts) {
    var c = opts.debug ? ',\n  ' : ', ',
        s = '});';
    if (js && js.slice(-1) !== '\n')
      s = '\n' + s;
    return imports + 'riot.tag2(\'' + name + SQ + c + _q(html, 1) + c + _q(css) + c + _q(attr) + ', function(opts) {\n' + js + s;
  }
  function splitBlocks(str) {
    if (/<[-\w]/.test(str)) {
      var m,
          k = str.lastIndexOf('<'),
          n = str.length;
      while (~k) {
        m = str.slice(k, n).match(END_TAGS);
        if (m) {
          k += m.index + m[0].length;
          m = str.slice(0, k);
          if (m.slice(-5) === '<-/>\n')
            m = m.slice(0, -5);
          return [m, str.slice(k)];
        }
        n = k;
        k = str.lastIndexOf('<', k - 1);
      }
    }
    return ['', str];
  }
  function getType(attribs) {
    if (attribs) {
      var match = attribs.match(TYPE_ATTR);
      match = match && (match[2] || match[3]);
      if (match) {
        return match.replace('text/', '');
      }
    }
    return '';
  }
  function getAttrib(attribs, name) {
    if (attribs) {
      var match = attribs.match(RegExp('\\s' + name + MISC_ATTR, 'i'));
      match = match && match[1];
      if (match) {
        return (/^['"]/).test(match) ? match.slice(1, -1) : match;
      }
    }
    return '';
  }
  function unescapeHTML(str) {
    return str.replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&#039;/g, '\'');
  }
  function getParserOptions(attribs) {
    var opts = unescapeHTML(getAttrib(attribs, 'options'));
    return opts ? JSON.parse(opts) : null;
  }
  function getCode(code, opts, attribs, base) {
    var type = getType(attribs),
        src = getAttrib(attribs, 'src'),
        jsParserOptions = extend({}, opts.parserOptions.js);
    if (src) {
      if (DEFER_ATTR.test(attribs))
        return false;
      var charset = getAttrib(attribs, 'charset'),
          file = path.resolve(path.dirname(base), src);
      code = require('fs').readFileSync(file, charset || 'utf8');
    }
    return _compileJS(code, opts, type, extend(jsParserOptions, getParserOptions(attribs)), base);
  }
  function cssCode(code, opts, attribs, url, tag) {
    var parserStyleOptions = extend({}, opts.parserOptions.style),
        extraOpts = {
          parserOpts: extend(parserStyleOptions, getParserOptions(attribs)),
          url: url
        };
    return _compileCSS(code, tag, getType(attribs) || opts.style, extraOpts);
  }
  function compileTemplate(html, url, lang, opts) {
    var parser = parsers._req('html.' + lang, true);
    return parser(html, opts, url);
  }
  var CUST_TAG = RegExp(/^([ \t]*)<(-?[A-Za-z][-\w\xA0-\xFF]*)(?:\s+([^'"\/>]+(?:(?:@|\/[^>])[^'"\/>]*)*)|\s*)?(?:\/>|>[ \t]*\n?([\S\s]*)^\1<\/\2\s*>|>(.*)<\/\2\s*>)/.source.replace('@', S_STRINGS), 'gim'),
      SCRIPTS = /<script(\s+[^>]*)?>\n?([\S\s]*?)<\/script\s*>/gi,
      STYLES = /<style(\s+[^>]*)?>\n?([\S\s]*?)<\/style\s*>/gi;
  function compile(src, opts, url) {
    var parts = [],
        included,
        defaultParserptions = {
          template: {},
          js: {},
          style: {}
        };
    if (!opts)
      opts = {};
    opts.parserOptions = extend(defaultParserptions, opts.parserOptions || {});
    included = opts.exclude ? function(s) {
      return opts.exclude.indexOf(s) < 0;
    } : function() {
      return 1;
    };
    if (!url)
      url = process.cwd() + '/.';
    var _bp = brackets.array(opts.brackets);
    if (opts.template) {
      src = compileTemplate(src, url, opts.template, opts.parserOptions.template);
    }
    src = cleanSource(src).replace(CUST_TAG, function(_, indent, tagName, attribs, body, body2) {
      var jscode = '',
          styles = '',
          html = '',
          imports = '',
          pcex = [];
      pcex._bp = _bp;
      tagName = tagName.toLowerCase();
      attribs = attribs && included('attribs') ? restoreExpr(parseAttribs(splitHtml(attribs, opts, pcex), pcex), pcex) : '';
      if ((body || (body = body2)) && /\S/.test(body)) {
        if (body2) {
          if (included('html'))
            html = _compileHTML(body2, opts, pcex);
        } else {
          body = body.replace(RegExp('^' + indent, 'gm'), '');
          body = body.replace(SCRIPTS, function(_m, _attrs, _script) {
            if (included('js')) {
              var code = getCode(_script, opts, _attrs, url);
              if (code === false)
                return _m.replace(DEFER_ATTR, '');
              if (code)
                jscode += (jscode ? '\n' : '') + code;
            }
            return '';
          });
          body = body.replace(STYLES, function(_m, _attrs, _style) {
            if (included('css')) {
              styles += (styles ? ' ' : '') + cssCode(_style, opts, _attrs, url, tagName);
            }
            return '';
          });
          var blocks = splitBlocks(body.replace(TRIM_TRAIL, ''));
          if (included('html')) {
            html = _compileHTML(blocks[0], opts, pcex);
          }
          if (included('js')) {
            body = _compileJS(blocks[1], opts, null, null, url);
            if (body)
              jscode += (jscode ? '\n' : '') + body;
            jscode = jscode.replace(IMPORT_STATEMENT, function(s) {
              imports += s.trim() + '\n';
              return '';
            });
          }
        }
      }
      jscode = /\S/.test(jscode) ? jscode.replace(/\n{3,}/g, '\n\n') : '';
      if (opts.entities) {
        parts.push({
          tagName: tagName,
          html: html,
          css: styles,
          attribs: attribs,
          js: jscode,
          imports: imports
        });
        return '';
      }
      return mktag(tagName, html, styles, attribs, jscode, imports, opts);
    });
    if (opts.entities)
      return parts;
    if (opts.debug && url.slice(-2) !== '/.') {
      if (/^[\\/]/.test(url))
        url = path.relative('.', url);
      src = '//src: ' + url.replace(/\\/g, '/') + '\n' + src;
    }
    return src;
  }
  module.exports = {
    compile: compile,
    html: compileHTML,
    style: _compileCSS,
    css: compileCSS,
    js: compileJS,
    parsers: parsers,
    version: 'v3.1.2'
  };
})(require('buffer').Buffer, require('process'));
