/* */ 
'use strict';

Object.defineProperty(exports, '__esModule', {
    value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

function _toConsumableArray(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) arr2[i] = arr[i]; return arr2; } else { return Array.from(arr); } }

var _utilSerialize = require('./util/serialize');

var _utilSerialize2 = _interopRequireDefault(_utilSerialize);

var _immutable = require('immutable');

exports['default'] = function (emitter, interceptors) {
    return function (payload, meta) {
        return interceptors.reduce(function (promise, interceptor) {
            return promise.then(function (currentPayload) {
                emitter.apply(undefined, ['pre', (0, _utilSerialize2['default'])(currentPayload)].concat(_toConsumableArray(meta), [interceptor.name]));
                return Promise.resolve(interceptor.apply(undefined, [(0, _utilSerialize2['default'])(currentPayload)].concat(_toConsumableArray(meta)))).then(function (nextPayload) {
                    emitter.apply(undefined, ['post'].concat(_toConsumableArray(nextPayload), _toConsumableArray(meta), [interceptor.name]));
                    return (0, _immutable.fromJS)(nextPayload);
                });
            });
        }, Promise.resolve(payload));
    };
};

module.exports = exports['default'];