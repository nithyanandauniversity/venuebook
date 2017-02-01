/* */ 
var validator = require('../is-my-json-valid@2.15.0.json!systemjs-json');
var validate = validator({
  type: 'object',
  properties: {hello: {
      required: true,
      type: 'string'
    }}
});
console.log('should be valid', validate({hello: 'world'}));
console.log('should not be valid', validate({}));
console.log('the errors were:', validate.errors);
