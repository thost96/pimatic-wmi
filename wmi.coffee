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


      
  class WmiSensor extends env.devices.Sensor   

    attributes:
      value:
        type: "string"
        description: "wmi fetched values"


    constructor: (@config) ->
      @id = @config.id
      @name = @config.name   
      @wmi = new wmiClient({ 
        username: @config.username,
        password: @config.password,
        host: @config.host
      })
      Promise.promisifyAll @wmi

      #console.log @wmi #Debugging

      @command = @config.command

      #Interval for pulling data
      setInterval( ( => 
        @getValue()
      ), @config.interval)
      
      super(@config)  
      
    destroy: () ->
      super()

    getValue: () ->
      @wmi.queryAsync(@command).then((results) ->
          console.log results #Debugging
          JSON.stringify results
      ).catch( (err) ->
        env.logger.error err
      )
    
  myWMI = new WMI
  return myWMI