# pimatic-wmi

[![npm version](https://badge.fury.io/js/pimatic-wmi.svg)](http://badge.fury.io/js/pimatic-wmi)

A pimatic plugin to query windows hosts using windows management instrumentation.

## Plugin Configuration
	{
          "plugin": "wmi",
          "debug": false
    }
The plugin has the following configuration properties:

| Property          | Default  | Type    | Description                                 |
|:------------------|:---------|:--------|:--------------------------------------------|
| debug             | false    | Boolean | Debug mode. Writes debug messages to the pimatic log, if set to true |



##Device Configuration
The following device can be used:

### WmiSensor
The WmiSensor displays the output of your specified command to the gui. 

	{
			"id": "wmi1",
			"class": "WmiSensor",
			"name": "WMI Sensor",
			"host": "",			
			"username": "",
			"password": "",
			"command": ""
	}

| Property          | Default  | Type    | Description                                 |
|:------------------|:---------|:--------|:--------------------------------------------|
| host              | -        | String  | Hostname or IP address of the Windows Host |
| username 			| - 	   | String  | local or domain user with administrative privileges |
| password 			| - 	   | String  | Password for the user specified |
| command 			| - 	   | String  | Command which will be executed  |
| interval 			| 60000    | Number  | The time interval in milliseconds at which the command is queried |

# ToDo

* Create Attributes dynamically from command response for easier usability in rules etc.

# History

See [Release History](https://github.com/thost96/pimatic-wmi/blob/master/HISTORY.md).

# License 

Copyright (c) 2016, Thorsten Reichelt. All rights reserved.

License: [GPL-2.0](https://github.com/thost96/pimatic-wmi/blob/master/LICENSE).