const yargs = require('yargs');

yargs.define = spec => {
  spec.define(yargs);
  return yargs;
};

module.exports = yargs;
