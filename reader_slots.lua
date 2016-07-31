-- This table define a round of access to sensor
-- Specify order and times you want access a sensor in a round
readerSlots = {
  cfg.readerId.nodeHeap,
  cfg.readerId.wifiSignal,
  -- cfg.readerId.externalTemp, -- This slot read both temp and humidity
  -- cfg.readerId.otherSensor,
}
