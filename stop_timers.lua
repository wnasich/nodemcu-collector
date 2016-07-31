for key, id in pairs(timerAllocation) do
  tmr.stop(id)
end
doTransmission()