expect = require('chai').expect
sinon = require('sinon')
yargs = require '../src/yargs'
commanderOptions = require '../src/commander-options'

yargs
  .define(commanderOptions)
  .option('other')
  .strict()

describe 'commander-options', () ->

  describe '--device', () ->

    it '--device cleware', () ->
      yargs.parse '--device cleware', (err, argv, output) ->
        expect(argv.device).to.equal 'cleware'
        expect(err).to.be.null
    it '--device wrong', () ->
      yargs.parse '--device wrong', (err, argv, output) ->
        expect(err.message).to.include 'Invalid values'
        expect(err.message).to.include 'Argument: device, Given: "wrong", Choices: "cleware"'

  describe '--device-path', () ->

    it '--device-path test/dummy-device', () ->
      yargs.parse '--device-path test/dummy-device', (err, argv, output) ->
        # take care of Windows paths as well
        expect(['test/dummy-device', 'test\\dummy-device']).to.include argv.devicePath
        expect(err).to.be.null

  describe '--selector', () ->

    it '--selector single', () ->
      yargs.parse '--selector single', (err, argv, output) ->
        expect(argv.selector).to.equal 'single'
        expect(err).to.be.null
    it '--selector multi', () ->
      yargs.parse '--selector multi', (err, argv, output) ->
        expect(argv.selector).to.equal 'multi'
        expect(err).to.be.null
    it '--selector wrong', () ->
      yargs.parse '--selector wrong', (err, argv, output) ->
        expect(err.message).to.include 'Invalid values'
        expect(err.message).to.include 'Argument: selector, Given: "wrong", Choices: "single", "multi"'
    it 'no selector given: --selector', () ->
      yargs.parse '--selector', (err, argv, output) ->
        expect(argv.selector).to.equal 'single'
        expect(err).to.be.null
    it 'no selector given, directly followed by another option: --selector --other', () ->
      yargs.parse '--selector', (err, argv, output) ->
        expect(argv.selector).to.equal 'single'
        expect(err).to.be.null

  describe 'resolveCommander', () ->

    {PhysicalTrafficLightSelector, PhysicalMultiTrafficLightSelector} =
      require('hello-lights').selectors

    beforeEach () ->
      # use sinon to prevent usb-detect to kick in with the ClewareSwitch1DeviceManager
      {Manager} = require 'hello-lights/lib/devices/cleware-switch1'
      @startMonitoring = sinon.stub(Manager, 'startMonitoring');
      @stopMonitoring = sinon.stub(Manager, 'stopMonitoring');
      @clewareManager = Manager

    afterEach () ->
      @startMonitoring.restore()
      @stopMonitoring.restore()

    it '--device cleware --selector single', () ->
      options =
        device: 'cleware'
        selector: 'single'
      commander = commanderOptions.resolveCommander(options)
      expect(commander.selector).to.be.an.instanceof PhysicalTrafficLightSelector
      expect(commander.selector.manager).to.equal @clewareManager

    it '--device cleware --selector multi', () ->
      options =
        device: 'cleware'
        selector: 'multi'
      commander = commanderOptions.resolveCommander(options)
      expect(commander.selector).to.be.an.instanceof PhysicalMultiTrafficLightSelector
      expect(commander.selector.manager).to.equal @clewareManager

    it '--device-path test/dummy-device', () ->
      options =
        devicePath: 'test/dummy-device'
        device: 'cleware' # ignored in the presence of --device-path
        selector: 'single'
      commander = commanderOptions.resolveCommander(options)
      expect(commander.selector.manager).to.equal require('./dummy-device').Manager
