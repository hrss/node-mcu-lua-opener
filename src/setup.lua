local wifi = require("wifi")
local tmr = require("tmr")

local app = require("application")
local config = require("config")

local module = {}

local function waitForIP()
  if wifi.sta.getip() == nil then
    print("IP unavailable, Waiting...")
  else
    tmr.stop(1)
    print("====================================")
    print("ESP8266 mode is: " .. wifi.getmode())
    print("MAC address is: " .. wifi.ap.getmac())
    print("IP is ".. wifi.sta.getip())
    print("====================================")

    app.start()
  end
end

local function connectToNetwork(aps)
  wifi.setmode(wifi.STATION);
  station_cfg={}
  station_cfg.ssid="{$SSID}"
  station_cfg.pwd="{$password}"
  wifi.sta.setip({ip="{$IP}",netmask="255.255.255.0",gateway="192.168.x.1"})
  wifi.sta.config(station_cfg)
  wifi.sta.connect()
  print("Connecting to " .. station_cfg.ssid .. " ...")

  tmr.alarm(1, 2500, 1, waitForIP)
end

function module.start()
  print("Configuring Wifi ...")
  wifi.setmode(wifi.STATION);
  connectToNetwork()
end

return module
