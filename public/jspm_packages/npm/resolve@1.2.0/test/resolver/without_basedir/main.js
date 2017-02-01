/* */ 
resolve = require('../../../../resolve@1.2.0.json!systemjs-json');
module.exports = function(t, cb) {
  resolve('mymodule', null, cb);
};
