/* */ 
"format cjs";
import serialize from './util/serialize';
import { fromJS } from 'immutable';

export default function (emitter, interceptors) {
    return (payload, meta) => interceptors.reduce(
        (promise, interceptor) => promise.then(currentPayload => {
            emitter('pre', serialize(currentPayload), ...meta, interceptor.name);
            return Promise.resolve(interceptor(serialize(currentPayload), ...meta))
                .then(nextPayload => {
                    emitter('post', ...nextPayload, ...meta, interceptor.name);
                    return fromJS(nextPayload);
                });
        }),
        Promise.resolve(payload)
    );
}
