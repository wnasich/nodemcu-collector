print('main ...')

require('ntp_sync')

-- fields: [1]delta tz, [2]readerId, [3]value
dataQueue = {}

function dataItemToString(dataItem)
  return dataItem[1] .. ',' .. dataItem[2] .. ',' .. dataItem[3]
end
function stringToDataItem(string)
  local dataItem = {}
  for t, r, v in string.gmatch(string, '(%d+),(%d+),(.+)') do
    dataItem[1] = t
    dataItem[2] = r
    dataItem[3] = v
  end
  return dataItem
end
function unrequire(m)
  package.loaded[m] = nil
  _G[m] = nil
end

-- drivers

-- readers
-- require('reader_temp_hum')
-- require('reader_others')

-- setup main events
require('transmission')
require('read_round')

-- Unrequire after 10 sec
tmr.alarm(timerAllocation.initAlarm, 10000, tmr.ALARM_SINGLE, function()
  unrequire('config')
  unrequire('config_local')
  unrequire('status')
  unrequire('timers')
  unrequire('reader_slots')
  unrequire('pins')
end)
