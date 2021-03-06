/* */ 
'use strict';

Object.defineProperty(exports, '__esModule', {
    value: true
});

var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

exports['default'] = function (callback, behaviour) {
    var interceptor = function interceptor(payload) {
        Promise.resolve(callback(payload)).then(function (result) {
            switch (behaviour) {
                case 'merge':
                default:
                    return _extends({}, payload, result);

                case 'replace':
                    return _extends({}, result);
            }
        });
    };

    interceptor.name = callback.name;

    return interceptor;
};

module.exports = exports['default'];