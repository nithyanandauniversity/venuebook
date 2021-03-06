/* */ 
"format cjs";
export default function (callback, behaviour) {
    const interceptor = payload => {
        Promise.resolve(callback(payload)).then(result => {
            switch (behaviour) {
            case 'merge':
            default:
                return { ...payload, ...result };

            case 'replace':
                return { ...result };
            }
        });
    };

    interceptor.name = callback.name;

    return interceptor;
}
