expect = require('chai').expect
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

    it '--device-path', () ->
      yargs.parse '--device-path ../cli', (err, argv, output) ->
        # take care of Windows paths
        expect(['../cli', '..\\cli']).to.include argv.devicePath
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

    xit '--device cleware --selector single', () ->
      options =
        device: 'cleware'
        selector: 'single'
      commander = commanderOptions.resolveCommander(options)
      # TODO: stub 'cleware'
