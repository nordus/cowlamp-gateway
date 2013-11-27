require('coffee-script');
require('./lib/main');

if(process.env.C9_PROJECT) process.env.NODE_ENV = 'test'