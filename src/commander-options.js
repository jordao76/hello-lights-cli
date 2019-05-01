const chalk = require('chalk');
const path = require('path');
const {Commander} = require('hello-lights');

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
    selectorCtor: resolveSelectorCtor(options),
    serialNum: options.serialNum
  });
}

/////////////////////////////////////////////////////////////////

function define(yargs) {
  yargs
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
    .option('serial-num', {
      alias: 'n',
      describe: 'serial number of device to use (only for "single" selector)' })
    .option('selector', {
      alias: 's',
      describe: 'selector type to use',
      choices: ['single', 'multi'],
      default: 'single' });
}

/////////////////////////////////////////////////////////////////

module.exports = {define, resolveCommander};

/////////////////////////////////////////////////////////////////
