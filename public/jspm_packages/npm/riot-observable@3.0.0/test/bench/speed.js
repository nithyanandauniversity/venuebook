/* */ 
var Benchmark = require('benchmark'),
    suite = new Benchmark.Suite(),
    expect = require('expect.js'),
    observable = require('../../../riot-observable@3.0.0.json!systemjs-json'),
    oldObservable = require('./old-observable'),
    oldEl = oldObservable(),
    el = observable(),
    iterationsCounter = 0,
    eventsCounter = 0;
suite.add('new-observable', function() {
  iterationsCounter++;
  el.trigger('foo');
}, {
  onStart() {
    iterationsCounter = 0;
    eventsCounter = 0;
    var fn = () => eventsCounter++;
    el.on('foo', fn);
  },
  onComplete() {
    expect(eventsCounter).to.be(iterationsCounter);
    el.off('*');
  }
}).add('old-observable', function() {
  iterationsCounter++;
  oldEl.trigger('foo');
}, {
  onStart() {
    iterationsCounter = 0;
    eventsCounter = 0;
    var fn = () => eventsCounter++;
    oldEl.on('foo', fn);
  },
  onComplete() {
    expect(eventsCounter).to.be(iterationsCounter);
    oldEl.off('*');
  }
}).on('cycle', function(event) {
  console.log(String(event.target));
}).on('complete', function() {
  console.log('Fastest is ' + this.filter('fastest').map('name'));
}).run();
