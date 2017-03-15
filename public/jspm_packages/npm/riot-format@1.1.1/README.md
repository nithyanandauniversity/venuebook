# riot-format

a helper library for [riotjs](https://github.com/riot/riot) to format displays,
without external dependencies, inspired by [$filter of angular](https://code.angularjs.org/1.5.9/docs/api/ng/service/$filter).

The original idea is to make it work with riot, but it can also work without riot.

[![NPM version][npm-version-image]][npm-url]
[![NPM downloads][npm-downloads-image]][npm-url]
[![MIT License][license-image]][license-url]

## why riot-format

- no external dependencies
- built-in format: [date(), number(), bytes(), json()](docs/api.md)
- chained format method calls
- easy to extend
- support modern browsers (IE9+)
- compatible with riot
- less than 5kb

## Get Started

install it from npm

```sh
npm install -D riot-format
```

### Use it with riot

mixin

```js
import format from 'riot-format'
import * as riot from 'riot'
format(riot) //mixin globally

```

use it in riot tag

```html
<app>
  <p>Today is { format(now, 'date', 'yyyy-mm-dd') }</p>

  this.now = new Date()
<app>
```

### Use it directly without riot

```js
import { format } from 'riot-format'
let formatter = format(new Date(), 'date', 'yyyy-mm-dd')
console.log(formatter.current)
//Note: formatter.current is lazily evaluated until you access it
```

For more information, see [Get Started](docs/getstarted.md)

## More

- [Advanced Usage](docs/advanced.md)

- [How to extend](docs/extend.md)

- [API](docs/api.md)

- [Typings](src/index.d.ts)

- [Examples](examples)

## Plans

- add currency support

## License

MIT

[license-image]:http://img.shields.io/badge/license-MIT-000000.svg?style=flat-square
[license-url]:LICENSE

[npm-version-image]:http://img.shields.io/npm/v/riot-format.svg?style=flat-square
[npm-downloads-image]:http://img.shields.io/npm/dm/riot-format.svg?style=flat-square
[npm-url]:https://npmjs.org/package/riot-format