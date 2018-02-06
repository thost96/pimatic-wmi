# pimatic-wmi

[![npm version](https://badge.fury.io/js/pimatic-wmi.svg)](http://badge.fury.io/js/pimatic-wmi)
[![dependencies status](https://david-dm.org/thost96/pimatic-wmi/status.svg)](https://david-dm.org/thost96/pimatic-wmi)
[![Build Status](https://travis-ci.org/thost96/pimatic-wmi.svg?branch=master)](https://travis-ci.org/thost96/pimatic-wmi)

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


## Device Configuration
The following device can be used:

#### WmiSensor
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
| host              | -        | String  | Hostname or IP address of the Windows Host|
| username 			| - 	   | String  | local or domain user with administrative privileges |
| password 			| - 	   | String  | Password for the user specified |
| command 			| - 	   | String  | Command which will be executed.  |
| interval 			| 60000    | Number  | The time interval in milliseconds  at which the command is queried |
| attributes		| -		   | Object  | Attributes are automatical saved to config for later support for rules | 

If you already created a WmiSensor device and you change the command later, all attributes from this device need to be deleted, before the new attributes are shown!

If you running pimatic on windows and want to query the local machine, you need to leave the username and password fields empty!

## Examples

For Examples see [WMI Queries](https://github.com/thost96/pimatic-wmi/blob/master/Examples.md).

## ToDo

* Add automatic clearing of attributes if command was changed

## History

See [Release History](https://github.com/thost96/pimatic-wmi/blob/master/History.md).

## License 

Copyright (c) 2016, Thorsten Reichelt and contributors. All rights reserved.

License: [GPL-2.0](https://github.com/thost96/pimatic-wmi/blob/master/LICENSE).
