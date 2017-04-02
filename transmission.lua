print('transmission ...')
local currentDataBlock = {}

function doTransmission()
  if (appStatus.transmitting) then
    return true
  end
  appStatus.transmitting = true

  local dataItem

  -- Fill up currrentDataBlock from data storage file
  if (appStatus.dataFileExists and #currentDataBlock == 0) then
    file.open(cfg.dataFileName)
    file.seek('set', appStatus.lastSeekPosition)
    print('Reading data storage')
    repeat
      dataItem = file.readline()
      if (dataItem) then
        dataItem = string.sub(dataItem, 1, (#dataItem - 1))
        print('Readline: ' .. dataItem)
        table.insert(currentDataBlock, dataItem)
      end
    until (dataItem == nil or #currentDataBlock >= cfg.transmissionBlock)

    if (dataItem == nil) then
      file.close()
      file.remove(cfg.dataFileName)
      appStatus.dataFileExists = false
      appStatus.lastSeekPosition = 0
    else
      appStatus.lastSeekPosition = file.seek()
      file.close()
    end
  end

  -- Fill up currentDataBlock from dataQueue
  if (#currentDataBlock == 0 and #dataQueue > 0) then
    local itemsToCopy
    if (#dataQueue > cfg.transmissionBlock) then
      itemsToCopy = cfg.transmissionBlock
    else 
      itemsToCopy = #dataQueue
    end

    repeat
      dataItem = table.remove(dataQueue)
      if (dataItem) then
        dataItem = stringToDataItem(dataItem)
        dataItem[1] = appStatus.baseTz + dataItem[1]
        table.insert(currentDataBlock, dataItemToString(dataItem))
      end
    until (dataItem == nil or #currentDataBlock >= cfg.transmissionBlock)
  end

  print('#dataQueue: ' .. #dataQueue .. ' #currentDataBlock: ' .. #currentDataBlock)

  if (#currentDataBlock > 0 and appStatus.wifiConnected) then
    sendCurrentBlock()
  else
    appStatus.transmitting = false
  end
end

function sendCurrentBlock()
  local tcpSocket
  tcpSocket = net.createConnection(net.TCP, 0)
  tcpSocket:connect(cfg.influxDB.port, cfg.influxDB.host)
  
  tcpSocket:on('connection', sendToInflux)

  tcpSocket:on('disconnection', function(sck, c)
    print('Socket disconnection')
    appStatus.transmitting = false

    if (#currentDataBlock == 0 and (#dataQueue > 0 or appStatus.dataFileExists)) then
      node.task.post(node.task.MEDIUM_PRIORITY, doTransmission)
    end
  end)

  tcpSocket:on('reconnection', function(sck, c)
    print('Socket reconnection')
    appStatus.transmitting = false
  end)

  tcpSocket:on('receive', function(sck, response)
    local findStart, findEnd
    print(response)

    findStart, findEnd = string.find(response, 'HTTP/1.1 200', 0, true)
    if (findStart) then
      currentDataBlock = {}
    end

    findStart, findEnd = string.find(response, 'HTTP/1.1 204 No Content', 0, true)
    if (findStart) then
      currentDataBlock = {}
    end
  end)

end

function sendToInflux(sck, c)
  local tagsLine = ''
  for tag, value in pairs(cfg.influxTags) do
    tagsLine = tagsLine .. tag .. '=' .. value .. ','
  end
  tagsLine = string.sub(tagsLine, 1, (#tagsLine - 1))
  
  local influxLines = ''
  for key, stringItem in pairs(currentDataBlock) do
    local dataItem = stringToDataItem(stringItem)
    if (dataItem[2] and dataItem[3]) then
      influxLines = influxLines ..
        influxMeasurement[0 + dataItem[2]] .. ',' .. tagsLine ..
        ' value=' .. dataItem[3] .. ' ' .. dataItem[1] .. '\n'
    end
  end

  local influxUri = '/write?db=' .. cfg.influxDB.dbname ..
    '&u=' .. cfg.influxDB.username .. '&p=' .. cfg.influxDB.password ..
    '&precision=s'

  local request =
    'POST ' .. influxUri .. ' HTTP/1.1\n' ..
    'Host: ' .. cfg.influxDB.host .. '\n' ..
    'Connection: close\n' ..
    'Content-Type: \n' ..
    'Content-Length: ' .. string.len(influxLines) .. '\n' ..
    '\n' .. influxLines

  print(request)

  sck:send(request)
end

tmr.register(
  timerAllocation.transmission,
  cfg.transmissionInterval,
  tmr.ALARM_AUTO,
  doTransmission
)
tmr.start(timerAllocation.transmission)

appStatus.dataFileExists = file.exists(cfg.dataFileName)
