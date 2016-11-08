# WMI Queries

In this document you can find many useful wmi queries and references for all wmi classes avaible. 

## General 

Wmi queries are build using SQL like query commands:

`SELECT something FROM class` 
or more specific using `where`
`SELECT something FROM class WHERE PropertyName Operator PropertyValue`

If you want to select all attributes of a wmi class, you can use the wildcard `*`. 

For more Win32 Classes you can search this references:

* [Win32 Classes](https://msdn.microsoft.com/en-us/library/aa394084(VS.85).aspx)
* [WMI Reference](https://msdn.microsoft.com/en-us/library/aa394572(VS.85).aspx) 
* [WMI Query Language](http://www.codeproject.com/Articles/46390/WMI-Query-Language-by-Example) 

or you can use this powershell command on the destination windows host to get all avaible classes:
`Get-WmiObject -List`

## Hardware

### Processor Info
`select * from Win32_Processor`

### Physical Memory in Bytes
`select TotalPhysicalMemory from Win32_ComputerSystem`

### Free Memory in Bytes
`select Name, AvailableBytes from Win32_PerfRawData_PerfOS_Memory`

### Physical Disk Info
`select DeviceID, Model, Caption from Win32_DiskDrive`

### Physical Disk Size in Bytes
`select Size from Win32_DiskDrive`

### Logical Disk Info
`select DeviceID, DriveType from Win32_LogicalDisk`

### Logical Disk Size and FreeSpace in Bytes
`select Size, FreeSpace from Win32_LogicalDisk`

### Logical information about network adapters
`select Name, PhysicalAdapter, Speed, MACAddress from Win32_NetworkAdapter`

### Bandwidth physical network adapter
`select Name, BytesReceivedPersec, BytesSentPersec, BytesTotalPersec, CurrentBandwidth from Win32_PerfFormattedData_Tcpip_NetworkInterface`

### Bandwidth logical network adapter
`select Name, BytesReceivedPersec, BytesSentPersec, BytesTotalPersec, CurrentBandwidth from Win32_PerfFormattedData_Tcpip_NetworkAdapter`

### Hardware Asset Tag
`select SMBIOSAssetTag from Win32_SystemEnclosure`

### Computer Manufacturer
`select Manufacturer from Win32_SystemEnclosure`

### Computer Model
`select Model from Win32_SystemEnclosure`

### Computer Serial
`select SerialNumber from Win32_SystemEnclosure`

### Chassis Type
`select ChassisTypes from Win32_SystemEnclosure`

Note: The chassis type field can be used to determine whether it's a mobile device (laptop or tablet) or a desktop. There is a problem sometimes because it is up to the OEM to determine the correct setting, and sometimes they get it wrong. Here are the codes that work most of the time:
`8 = Tablet`  
`9 - 14 = Laptop`
`Everything Else = Desktop or Server`

## System Information

### Operation System
`select CSName, Caption, Version  from Win32_OperatingSystem`

### Date and Time
`select * from Win32_LocalTime`

### Complete Software List
`select * from Win32_Product`

### Computer System
`select * from Win32-ComputerSystem`

### Hostname
`select Name from Win32_ComputerSystem`

### Process List
`select * from Win32_Process`

It's also possible to just monitor one Process with this query:
`select * from Win32_Process where ProcessId = <value>`

### Service List 
`select * from Win32_Service`

It's also possible to just monitor one Service with this query:
`select * from Win32_Service where Name = <value>`

### Printers
`select Caption, DriverName, PortName from Win32_Printer`

## Performance Data

### Processor
`select * from Win32_PerfRawData_PerfOS_Processor`

### Memory
`select * from Win32_PerfRawData_PerfOS_Memory`

### Network 
`select * from Win32_PerfRawData_Tcpiip_NetworkInterface`

