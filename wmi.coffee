capitalizeFirstLetter = (string) =>
  return string.charAt(0).toUpperCase() + string.slice(1)

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
    
    ###
    #param @config device configuration
    #param @plugin used for plugin wide debug settings (true or false)
    #param @framework used for recreting the device with generated attributes
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
      if @debug
        env.logger.debug @wmi 

      if !_.isEmpty(@config.attributes)
        @attributes = @config.attributes
        for attrName, object of @config.attributes
          @_createGetter(attrName, () => 
            Promise.resolve @attributes[attrName].value
          ) 
          setInterval(
            ( =>
              @readWmiData(attrName)
              @['get' + (capitalizeFirstLetter attrName)]()
            ), @config.interval
          )     
      else
        debug = @debug
        attributes = @attributes
        config = @config
        framework = @framework
        deviceobj = @
        
        @wmi.queryAsync(@command).then((results) ->
            results = results[0]
            if debug
              env.logger.debug JSON.stringify(results) 
            
            @attr = _.cloneDeep(attributes)          
            for attrName, value of results 
              type = null
              if _.isNumber(value) 
                type = "number"
              else if _.isBoolean(value)
                type = "boolean"
              else if _.isDate(value)
                type = "string"
              else
                type = "string"

              @attr[attrName] = {
                type: type
                description: attrName 
                value: value
              }
            if debug
              env.logger.debug @attr
            
            config.attributes = @attr
            framework.deviceManager.recreateDevice(deviceobj, config)
        )
          
      super(@config, @plugin, @framework)  
      
    destroy: () ->
      super()

    readWmiData: (attrName) =>
      command = @command
      debug = @debug
      attributes = @attributes
      config = @config
      @wmi.queryAsync(command).then( (results) ->
        if debug
          env.logger.debug attrName + ' : ' + results[0][attrName]
        attributes[attrName].value = results[0][attrName]
        config.attributes[attrName].value = results[0][attrName]
        Promise.resolve attributes[attrName].value
      )

  return new WMI