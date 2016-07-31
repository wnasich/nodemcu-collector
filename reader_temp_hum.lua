function readTempHum()
  local status, temp, humi, temp_dec, humi_dec = dht.read(gpioPins.dht)
  
  if status == dht.OK then
  elseif status == dht.ERROR_CHECKSUM then
      temp, humi = nil, nil
      print('DHT Checksum error.')
  elseif status == dht.ERROR_TIMEOUT then
      temp, humi = nil, nil
      print('DHT timed out.')
  end
  
  return temp, humi
end
