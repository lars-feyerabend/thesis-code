#!/usr/bin/env node

var jsdom = require('jsdom');
var arg = process.argv;
var fs = require('fs');

if (process.argv.length != 3) {
  console.log('Wrong number of arguments!');
  process.exit(1);
}

var base = process.argv[2];

var doc = fs.readFileSync('/dev/stdin').toString();

jsdom.env(doc, [
    'http://code.jquery.com/jquery.min.js'
  ],
  function(errors, window) {
    if (errors) {
      console.log('ERROR');
      console.log(doc);
      process.exit(1);
    }

    // window.$('link[rel=stylesheet]').each(function() { css.push(this.href); });
    // window.$('script[src]').each(function() { js.push(this.src); });
    
    window.$('img').each(function() { this.src = base + this.src });
    
    console.log(window.document.body.innerHTML);
});