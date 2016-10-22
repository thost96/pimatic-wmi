module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  wmiClient = require 'wmi-client'

  class WMI extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      deviceConfigDef = require("./device-config-schema")
      @framework.deviceManager.registerDeviceClass("WmiSensor", {
        configDef: deviceConfigDef.WmiSensor,
        createCallback: (config) => new WmiSensor(config, @, @framework)
      })    
      
  class WmiSensor extends env.devices.Sensor   

    attributes:
      value:
        type: "string"
        description: "wmi fetched values"

    ###
    #param @config device configuration
    #param @plugin used for plugin wide debug settings (true or false)
    #param @framework used to trigger recreateDevice
    ### 
    constructor: (@config, @plugin, @framework) ->
      ###
      #param @id = device id set by user
      #param @name = device name set by user
      #param @debug = plugin wide debug setting (true or false)
      #param @command = command specified by user 
      ###
      @id = @config.id
      @name = @config.name  
      @debug = @plugin.config.debug 
      @command = @config.command
      ###
      #WMI Object 
      #param @config.username = destination admin user (local or domain(no domain prefix / suffix required))
      #param @config.password = password for destination admin user
      #param @config.host = destination for wmi query
      ###
      @wmi = new wmiClient({ 
        username: @config.username,
        password: @config.password,
        host: @config.host
      })
      Promise.promisifyAll @wmi
      #if @debug
      #  env.logger.debug @wmi 

      setInterval( ( => 
        @getValue()
      ), @config.interval)
      
      super(@config, @plugin, @framework)  
      
    destroy: () ->
      super()

    capitalizeFirstLetter = (string) =>
      return string.charAt(0).toUpperCase() + string.slice(1)

    addGetter = (attributeName) =>
      attributeName = attributeName.toLowerCase()
      @['_' + attributeName] = 0
      @['get' + (capitalizeFirstLetter attributeName)] = () =>
          if @debug
            env.logger.debug @['_' + attributeName] 
          Promise.resolve(@['_' + attributeName]) 

    getValue: () ->
      debug = @debug
      @wmi.queryAsync(@command).then((results) ->
          results = results[0] #array with json object to json object only
          if debug
            env.logger.debug JSON.stringify(results)

          #building attributes 
          attr = {}
          for key, value of results
            type = null
            if _.isNumber(value) 
              type = "number"
            else if _.isBoolean(value)
              type = "boolean"
            else if _.isDate(value)
              type = "string"
            else
              type = "string"
            attrName = key
            attr[attrName] = {
              type: type
              description: attrName
              value: value
            }
            #building get function for each attribute
            addGetter attrName
          if debug
            env.logger.debug attr

          #Sample command:
          #SELECT FreeSpace FROM Win32_LogicalDisk WHERE DeviceId = "C:"
          #Output from command above:
          # {"DeviceID":"C:","FreeSpace":23983808512}
          #And Output with attributes build:
          # { DeviceID: { type: 'string', description: 'DeviceID', value: 'C:' }, FreeSpace: { type: 'number', description: 'FreeSpace', value: 23983808512 } }

          #How to save this attributes to the device?
          #How to recreate a device with this attributes?

          #Recreate WmiSensor 
          #framework.deviceManager.recreateDevice(olddevice, newDevice)

          JSON.stringify results
      ).catch( (err) ->
        env.logger.error err
      )
    
  return new WMI