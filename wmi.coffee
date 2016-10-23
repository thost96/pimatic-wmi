module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  wmiClient = require 'wmi-client'
  events = require 'events'

  class WMI extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      deviceConfigDef = require("./device-config-schema")
      @framework.deviceManager.registerDeviceClass("WmiSensor", {
        configDef: deviceConfigDef.WmiSensor,
        createCallback: (config) => new WmiSensor(config, @)
      })    

  class AttributeContainer extends events.EventEmitter
    constructor: () ->
      @values = {}
      
  class WmiSensor extends env.devices.Sensor   
    
    ###
    #param @config device configuration
    #param @plugin used for plugin wide debug settings (true or false)
    ### 
    constructor: (@config, @plugin) ->
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
      
      debug = @debug
      deviceobj = @
      attributes = @attributes

      setInterval( ( =>
        @wmi.queryAsync(@command).then((results) ->

            @attrValues = new AttributeContainer()
            @attr = _.cloneDeep(attributes)

            results = results[0] #array with json object to json object only
            if debug
              env.logger.debug JSON.stringify(results)
              # {"DeviceID":"C:","FreeSpace":23983808512}
            
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
              # { DeviceID: { type: 'string', description: 'DeviceID', value: 'C:' } }
              # { DeviceID: { type: 'string', description: 'DeviceID', value: 'C:' }, FreeSpace: { type: 'number', description: 'FreeSpace', value: 23983198208 } }

              @attrValues.values[attrName] = value
              @attrValues.emit attrName, value
              if debug
                env.logger.debug @attrValues
              #AttributeContainer { values: { DeviceID: 0 } }
              #AttributeContainer { values: { DeviceID: 0, FreeSpace: 0 }, _events: { '': [Function] }, _eventsCount: 1 }      

              deviceobj._createGetter(attrName, => 
                return Promise.resolve @attrValues.values[attrName]             
              ) 
        )
      ), @config.interval)
          
      super(@config, @plugin)  
      
    destroy: () ->
      super()
    
  return new WMI