#!/usr/bin/env node

const yargs = require('./src/yargs');

yargs
  .define(require('./src/commander-options'))
  .define(require('./src/exec-command'))
  .scriptName('hello-lights')
  .demandCommand(1, 'What is your command?')
  .epilogue('for more info, check out https://github.com/jordao76/hello-lights-cli')
  .strict()
  .help()
  .parse();
