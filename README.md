# nodemcu-collector
Collect measurements from sensors connected to NodeMCU and transmit them to InfluxDB.

This project is intended as starting point for projects where you have to collect data from a set of sensors connected to ESP8266 and any othe IoT platform that support NodeMCU firmware.

## Requirements
* A [ESP8266 module](https://en.wikipedia.org/wiki/ESP8266) or similar 
* Knowledge about [NodeMCU platform](http://nodemcu.readthedocs.io/en/master/) and [Lua programming language](http://www.lua.org/manual/5.1/index.html)
* A NodeMCU firmware compiled with these modules at least: bit,dht,file,gpio,i2c,net,node,rtctime,sntp,tmr,uart,wifi . You can compile it easly using http://nodemcu-build.com/
* [ESplorer](https://github.com/4refr0nt/ESPlorer) for edit and upload code to the module
* An accessible instance of [InfluxDB server](https://influxdata.com/time-series-platform/influxdb/)

## Assumptions
* You want collect data from sensors without interaction
* You need the most fiability as possible. It means support wifi or influxdb shutdowns with minor data loss.
* You supply energy to module using a mini UPS device.  

## Installation
* Clone or [Download](https://github.com/wnasich/nodemcu-collector/archive/master.zip) this repository 
* Edit `config.lua` and `config_local.lua` according to your environment
* Upload all these files to NodeMCU module and reset it
* Inspect output of serial console of module, you should see a succesful wifi connection info.
* Start sending basic measurements to InfluxDB, type on console: `require('main')`
* Check data captured on InfluxDB. You will get these measurements: `node_heap`, `wifi_signal`, `node_event`

### Donations
```
Bitcoin : 187w4iNVHX44y2PC96AuhP286aUKNjcrXV
Litecoin: LVutsPn9jaoC6SScdxsGMM2uAMvPbjNZXq
PIVX    : D81ZZt8jAvWQFaLhtx3f4ntstUCCYBcdne
```
