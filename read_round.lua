print('read_round ...')

-- For comparing against captureDelta
local lastValues = {}

function doReadRound()
  local value
  
  -- Detect start of node
  if (status.lastRoundSlot == 0) then
    addToDataQueue(cfg.readerId.nodeEvent, '"start"')
  end

  if (status.lastRoundSlot > #readerSlots) then
    status.lastRoundSlot = 0
  end
  status.lastRoundSlot = status.lastRoundSlot + 1

  -- Node heap
  if (readerSlots[status.lastRoundSlot] == cfg.readerId.nodeHeap) then
    value = node.heap()
    if (greaterThanDelta(cfg.readerId.nodeHeap, value)) then
      addToDataQueue(cfg.readerId.nodeHeap, value)
    end

  -- Wifi signal
  elseif (readerSlots[status.lastRoundSlot] == cfg.readerId.wifiSignal) then
    value = wifi.sta.getrssi()
    if (value and greaterThanDelta(cfg.readerId.wifiSignal, value)) then
      addToDataQueue(cfg.readerId.wifiSignal, value)
    end
  
  -- External temp and humidity
  --[[
  elseif (readerSlots[status.lastRoundSlot] == cfg.readerId.externalTemp) then
    -- This reader gets cfg.readerId.externalHum also
    local tempValue, humValue = readTempHum()

    if (tempValue and greaterThanDelta(cfg.readerId.externalTemp, tempValue)) then
      addToDataQueue(cfg.readerId.externalTemp, tempValue)
    end

    if (humValue and greaterThanDelta(cfg.readerId.externalHum, humValue)) then
      addToDataQueue(cfg.readerId.externalHum, humValue)
    end
  ]]

  -- Other sensor
  --[[
  elseif (readerSlots[status.lastRoundSlot] == cfg.readerId.pressureHigh) then
    value = readPressure(cfg.readerId.pressureHigh)
    if (valud and greaterThanDelta(cfg.readerId.pressureHigh, value)) then
      addToDataQueue(cfg.readerId.pressureHigh, value)
    end
  ]]
  end

end

function addToDataQueue(measurementId, value)
  local dataItem, deltaTz

  if (#dataQueue == 0) then
    status.baseTz = rtctime.get()
    deltaTz = 0
  else
    deltaTz = rtctime.get() - status.baseTz
  end

  dataItem = {deltaTz, measurementId, value}

  print('tz: ' .. dataItem[1], 'Reader Id: ' .. dataItem[2], 'Value: ' .. dataItem[3])
  table.insert(dataQueue, dataItemToString(dataItem))

  -- When last heap lower than config value then save dataQueue to file
  local lastNodeHeap = lastValues[cfg.readerId.nodeHeap]
  if (lastNodeHeap and lastNodeHeap <= cfg.toFileWhenHeap) then
    file.open(cfg.dataFileName, 'a+')

    local itemsToCopy = #dataQueue
    for i = 1, itemsToCopy do
      dataItem = table.remove(dataQueue)
      if (dataItem) then
        dataItem = stringToDataItem(dataItem)
        dataItem[1] = status.baseTz + dataItem[1]
        file.writeline(dataItemToString(dataItem))
      end
    end
    print('Items added to storage: ' .. itemsToCopy)
    file.close()
    status.dataFileExists = true
  end
end

function greaterThanDelta(readerId, currentValue)
  local isGreater = (
    lastValues[readerId] == nil or
    math.abs(lastValues[readerId] - currentValue) > captureDelta[readerId]
  )
  if (isGreater) then
    lastValues[readerId] = currentValue
  end

  return isGreater
end

tmr.register(
  timerAllocation.readRound,
  cfg.readRoundInterval,
  tmr.ALARM_AUTO,
  doReadRound
)
tmr.start(timerAllocation.readRound)
