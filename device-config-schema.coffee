module.exports = {
	title: "WMI Device config schemas"
	WmiSensor: 
	  	title: "WmiSensor config options"
	  	type: "object"
	  	properties: 
        host: 
          description: "target host ip address"
          type: "string"
        username: 
          description: "target host local user"
          type: "string"
        password:
          description: "target host local user password"
          type: "string"
        command:
          description: "wmi event"
          type: "string"
        interval:
          description: "interval"
          type: "number"
          default: 60000
        attributes:
          description: "attributes"
          type: "object"
}