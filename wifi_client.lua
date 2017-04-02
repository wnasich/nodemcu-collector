print('wifi_client ...')

wifi.setphymode(cfg.wifiMode)
wifi.setmode(wifi.STATION)

print('MAC: ', wifi.sta.getmac())
print('chip: ', node.chipid())
print('heap: ', node.heap())

if (cfg.wifiIp) then
  wifi.sta.setip({
    ip = cfg.wifiIp,
    netmask = '255.255.255.0',
    gateway = cfg.wifiGateway
  })
end

wifi.sta.config(cfg.wifiSsid, cfg.wifiPass)

wifi.sta.eventMonReg(wifi.STA_GOTIP, function()
    print("STATION_GOT_IP")
    print("WiFi connection established, IP address: " .. wifi.sta.getip())
    status.wifiConnected = true
end)

wifi.sta.eventMonReg(wifi.STA_CONNECTING, function(previousState)
    if(previousState == wifi.STA_GOTIP) then 
        print("Station lost connection with access point\n\tAttempting to reconnect...")
        status.wifiConnected = false
    else
        print("STATION_CONNECTING")
    end
end)

wifi.sta.eventMonStart()

net.dns.setdnsserver(cfg.dns0, 0)
net.dns.setdnsserver(cfg.dns1, 1)
