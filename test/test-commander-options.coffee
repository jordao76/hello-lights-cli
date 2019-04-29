expect = require('chai').expect
sinon = require 'sinon'
yargs = require '../src/yargs'
commanderOptions = require '../src/commander-options'

describe 'commander-options', () ->

  beforeEach () ->
    run = sinon.stub()
    close = sinon.stub()
    stubCommander = { run, close }
    @resolveCommander = sinon.stub(commanderOptions, 'resolveCommander')
      .returns stubCommander

  afterEach () ->
    @resolveCommander.restore()

  describe '--device', () ->

    it 'default --device is cleware', () ->
      yargs.parse 'exec hello', (err, argv, output) ->
        expect(argv.device).to.equal 'cleware'
        expect(err).to.be.null
    it '--device cleware', () ->
      yargs.parse '--device cleware exec hello', (err, argv, output) ->
        expect(argv.device).to.equal 'cleware'
        expect(err).to.be.null
    it '--device wrong', () ->
      yargs.parse '--device wrong exec hello', (err, argv, output) ->
        expect(err.message).to.include 'Invalid values'
        expect(err.message).to.include 'Argument: device, Given: "wrong", Choices: "cleware"'

  describe '--device-path', () ->

    it '--device-path has no default', () ->
      yargs.parse 'exec hello', (err, argv, output) ->
        expect(argv.devicePath).to.be.undefined
        expect(err).to.be.null
    it '--device-path test/dummy-device', () ->
      yargs.parse '--device-path test/dummy-device exec hello', (err, argv, output) ->
        # take care of Windows paths as well
        expect(['test/dummy-device', 'test\\dummy-device']).to.include argv.devicePath
        expect(err).to.be.null

  describe '--selector', () ->

    it 'default --selector is single', () ->
      yargs.parse 'exec hello', (err, argv, output) ->
        expect(argv.selector).to.equal 'single'
        expect(err).to.be.null
    it '--selector single', () ->
      yargs.parse '--selector single exec hello', (err, argv, output) ->
        expect(argv.selector).to.equal 'single'
        expect(err).to.be.null
    it '--selector multi', () ->
      yargs.parse '--selector multi exec hello', (err, argv, output) ->
        expect(argv.selector).to.equal 'multi'
        expect(err).to.be.null
    it '--selector wrong', () ->
      yargs.parse '--selector wrong exec hello', (err, argv, output) ->
        expect(err.message).to.include 'Invalid values'
        expect(err.message).to.include 'Argument: selector, Given: "wrong", Choices: "single", "multi"'
    it 'no selector given: --selector', () ->
      yargs.parse '--selector exec hello', (err, argv, output) ->
        expect(err.message).to.include 'Invalid values'
        expect(err.message).to.include 'Argument: selector, Given: "exec", Choices: "single", "multi"'

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
