print('main.lua')

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

-- readers
-- require('reader_temp_hum')
-- require('reader_others')

-- setup main events
require('transmission')
require('read_round')

print('/main.lua')
