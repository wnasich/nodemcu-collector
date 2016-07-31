cfg = {
  nodeCpuFreq = node.CPU80MHZ, -- node.CPU160MHZ
  wifiSsid = 'WiFi Name',
  wifiPass = 'super-secret',
  wifiMode = wifi.PHYMODE_B,
  wifiIp = '192.168.1.140',
  wifiGateway = '192.168.1.1',
  dns0 = '192.168.1.1',
  dns1 = '8.8.4.4',
  telnetPort = 23,
  production = true,
  
  transmissionBlock = 10, -- Measurements to send
  transmissionInterval = 60000, -- miliseconds
  readRoundInterval = 10000, -- miliseconds
  toFileWhenHeap = 8000, -- lower than in bytes
  dataFileName = 'data_storage.csv',
  
  readerId = {
    nodeHeap = 1,
    wifiSignal = 2,
    nodeEvent = 3, -- DO NOT put this on var readerSlots
    externalTemp = 4, -- This reader gets externalHum also
    externalHum = 5, -- DO NOT put this on var readerSlots
  },
  
  influxDB = {},
  influxTags = {},
  
  sntpServerName = '0.pool.ntp.org',
  sntpServerIp = '200.160.7.193',
  sntpRefresh = 24 -- hours
}

influxMeasurement[cfg.readerId.nodeHeap] = 'node_heap'
influxMeasurement[cfg.readerId.wifiSignal] = 'wifi_signal'
influxMeasurement[cfg.readerId.nodeEvent] = 'node_event'
influxMeasurement[cfg.readerId.externalTemp] = 'external_temp'
influxMeasurement[cfg.readerId.externalHum] = 'external_hum'

-- After read a value it is enqueued only when greater than related captureDelta
captureDelta[cfg.readerId.nodeHeap] = 1
captureDelta[cfg.readerId.wifiSignal] = 0.01
captureDelta[cfg.readerId.externalTemp] = 0.1
captureDelta[cfg.readerId.externalHum] = 0.4
