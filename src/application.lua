local net = require("net")
local wifi = require("wifi")
local tmr = require("tmr")
local gpio = require("gpio")
local uart = require("uart")
local config = require("config")
local tls = require("tls")
local sjson = require("sjson")
local ledStatus = false
local module = {}
local node = require("node")

local homepage = [[
  <!DOCTYPE HTML>
  <html>
    <head>
      <meta content="text/html; charset=utf-8">
      <title>ESP8266</title>
      <style type="text/css">
        html, body {
          min-height: 100%;
        }
        body {
          font-family: monospace;
          background: url(http://i.imgur.com/rqJrop4.gif) no-repeat 0 0 #5656fa;
          background-size: cover;
          margin: 0;
          padding: 10px;
          text-align: center;
          color: #56f2ff;
        }
      </style>
    </head>
    <body>
      NodeMCU Server
    </body>
  </html>
]]

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

local auth = {}

local function decodeRequest(request)
  response = request:match("%{(.-)%}")
  if response ~= nil then
    response = "{" .. response .. "}"
    result = sjson.decode(response)
    return result
  end
end

local function ledOn()
  led = 2 -- NodeMCU uses a different numbering scheme
  gpio.write(led, gpio.HIGH)
end

local function ledOff()
  led = 2 -- NodeMCU uses a different numbering scheme
  gpio.write(led, gpio.LOW)
end

--86:f3:eb:6f:98:e5 MAC ADDRESS
local function runServer()
  auth["hernando.sas@gmail.com"] = 1
  local s = net.createServer(net.TCP)
  led = 3
  print("====================================")
  print("Server Started")
  print("Open " .. wifi.sta.getip() .. " in your browser")
  print("====================================")

  s:listen(config.PORT, function(connection)
    connection:on("receive", function(c, request)
      print(request)
      req = split(request, " ")
      method = req[1]
      if method == "POST" and req[2] == "/some-endpoint" then

        if {"put some sort of validation here"} then
          ledOn()
          tmr.alarm(1, 500, tmr.ALARM_SINGLE, ledOff)
        end
        c:send(homepage)
      end
      if method == "GET" then
        c:send(homepage)
      end
    end)

    connection:on("sent", function(c) c:close() end)
  end)
end

function module.start()

  runServer()

end

return module
