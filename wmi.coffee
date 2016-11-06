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
      # mwittig: This is to keep track of all interval timers. we need to remove them on destruction
      @timers = []
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

      if not _.isEmpty(@config.attributes)
        @attributes = @config.attributes
        # mittig: added 'own' keyword to for loop, removed 'object' as unused
        for own attrName of @config.attributes
          # mwittig: need closure here as attrName is used in async function below (setInterval)
          do (attrName) =>
            @_createGetter(attrName, () =>
              # mwittig: added error handling to the getter function
              if @attributes[attrName]?
                if @attributes[attrName].value?
                  Promise.resolve @attributes[attrName].value
                else
                  Promise.reject "Invalid value for attribute: #{attrName}"
              else
                Promise.reject "No such attribute: #{attrName}"
            )
            #mwittig: push setInterval result to timers to be able to clearTimers on destruction
            @timers.push setInterval(
              ( =>
                @readWmiData(attrName)
                @['get' + (capitalizeFirstLetter attrName)]()
              ), @config.interval
            )
      else
        # mwittig: bind queryAsync to this: =>. this way you don't need  the holder variables which I removed
        @wmi.queryAsync(@command).then((results) =>
          # mwittig: need to check for empty result here - we will loop forever otherwise
          if results.length > 0
            results = results[0]
            if @debug
              env.logger.debug JSON.stringify(results) 
            
            @attr = _.cloneDeep(@attributes)
            # mittig: added 'own' keyword
            for own attrName, value of results
              type = null
              if _.isNumber(value)
                type = "number"
              else if _.isBoolean(value)
                type = "boolean"
              else if _.isDate(value)
                type = "string"
              else
                type = "string"

              # mwittig: added acronym to have label on display
              @attr[attrName] = {
                type: type
                description: attrName
                value: value
                acronym: attrName
              }
            if @debug
              env.logger.debug @attr

            @config.attributes = @attr
            @framework.deviceManager.recreateDevice(@, @config)
          else
            env.logger.error "empty result for wmi query #{@command}"
        )
          
      super(@config, @plugin, @framework)  
      
    destroy: () ->
      # clear timers
      for timerId in @timers
        clearInterval timerId
      super()

    readWmiData: (attrName) ->
      # mwittig: bind queryAsync to this: =>. this way you don't need  the holder variable which I removed
      @wmi.queryAsync(@command).then( (results) =>
        if @debug
          env.logger.debug attrName + ' : ' + results[0][attrName]
        # emit attribute change event
        if @config.attributes[attrName].value isnt results[0][attrName] or not @config.attributes[attrName].discrete
          @emit attrName, results[0][attrName]
        @attributes[attrName].value = results[0][attrName]
        @config.attributes[attrName].value = results[0][attrName]
        Promise.resolve @attributes[attrName].value
      )

  return new WMI