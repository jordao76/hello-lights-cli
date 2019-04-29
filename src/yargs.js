const yargs = require('yargs');

yargs.define = spec => {
  spec.define(yargs);
  return yargs;
};

yargs
  .define(require('./commander-options'))
  .define(require('./exec-command'))
  .scriptName('hello-lights')
  .demandCommand(1, 'What is your command?')
  .epilogue('for more info, check out https://github.com/jordao76/hello-lights-cli')
  .strict()
  .help()

module.exports = yargs;
