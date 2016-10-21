module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  #wmiClient = Promise.promisifyAll(require 'wmi-client')
  wmiClient = require 'wmi-client'

  class WMI extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      deviceConfigDef = require("./device-config-schema")
      @framework.deviceManager.registerDeviceClass("WmiSensor", {
        configDef: deviceConfigDef.WmiSensor,
        createCallback: (config) => new WmiSensor(config)
      })    

  plugin = new WMI
      
  class WmiSensor extends env.devices.Sensor   

    attributes:
      value:
        type: "string"
        description: "wmi fetched values"

    constructor: (@config) ->
      @id = @config.id
      @name = @config.name   
      @command = @config.command
      @wmi = new wmiClient({ 
        username: @config.username,
        password: @config.password,
        host: @config.host
      })
      Promise.promisifyAll @wmi
      if plugin.config.debug
        env.logger.debug @wmi 

      setInterval( ( => 
        @getValue()
      ), @config.interval)
      
      super(@config)  
      
    destroy: () ->
      super()

    getValue: () ->
      @wmi.queryAsync(@command).then((results) ->
          if plugin.config.debug 
            env.logger.debug results 
          JSON.stringify results
      ).catch( (err) ->
        env.logger.error err
      )
    
  return plugin