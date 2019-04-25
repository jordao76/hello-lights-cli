#!/usr/bin/env node

const {Commander} = require('hello-lights');
const chalk = require('chalk');
const path = require('path');

/////////////////////////////////////////////////////////////////

const logger = {
  log: (...args) => {
    console.log(chalk.gray(...args));
  },
  error: (...args) => {
    console.error(chalk.red(...args));
  }
};

/////////////////////////////////////////////////////////////////

require('yargs')
  .scriptName("hello-lights")
  .option('device', {
    alias: 'd',
    describe: 'device type to use',
    choices: ['cleware'],
    default: 'cleware',
    hidden: true }) // un-hide when more than one option exists
  .option('device-path', {
    alias: 'p',
    describe: 'device type path to use, overrides --device',
    normalize: true,
    hidden: true }) // hide advanced option
  .option('selector', {
    alias: 's',
    describe: 'selector type to use',
    choices: ['single', 'multi'],
    default: 'single' })
  .command('exec <cmd>', 'executes a command',
    yargs => yargs.positional('cmd', { describe: 'command to execute' }),
    argv => exec(argv, argv.cmd, argv._.slice(1))) // argv._ includes 'exec' at index 0
  .example('$0 exec bounce 300', '# executes the `bounce 300` command')
  .demandCommand(1, 'What is your command?')
  .epilogue('for more info, check out https://github.com/jordao76/hello-lights')
  .strict()
  .help()
  .parse();

/////////////////////////////////////////////////////////////////

function resolveDeviceManager(options) {
  const clewareDevicePath = 'hello-lights/lib/devices/cleware-switch1';
  let devicePath;
  if (options.devicePath) {
    devicePath = path.resolve(options.devicePath);
  }
  else {
    // for now, it is always the case that: options.device === 'cleware'
    devicePath = clewareDevicePath;
  }
  let {Manager} = require(devicePath);
  return Manager;
}

/////////////////////////////////////////////////////////////////

function resolveSelectorCtor(options) {
  const selectorProperty =
    options.selector === 'multi' ? 'PhysicalMultiTrafficLightSelector'
      : 'PhysicalTrafficLightSelector'; // options.selector === 'single'
  return require('hello-lights').selectors[selectorProperty];
}

/////////////////////////////////////////////////////////////////

function resolveCommander(options) {
  return new Commander({
    logger,
    manager: resolveDeviceManager(options),
    selectorCtor: resolveSelectorCtor(options)
  });
}

/////////////////////////////////////////////////////////////////

async function exec(options, cmd, cdr = []) {
  let commander = resolveCommander(options);
  cdr.unshift(cmd);
  let command = cdr.join(' ');
  await commander.run(command);
  commander.close();
}

/////////////////////////////////////////////////////////////////
