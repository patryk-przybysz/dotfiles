--!nonstrict

-- Lights the Control Center tile while the saved "Hotspot" profile is active.
-- SSID, password, and channel stay in NetworkManager (nm-connection-editor).

local CONN = "Hotspot"
local active = false
local generation = 0

local function render()
  shortcut.setLabel("Hotspot")
  shortcut.setIcon("wifi", "wifi-off")
  shortcut.setActive(active)
  shortcut.setEnabled(true)
end

local function connectionIsUp(stdout)
  for line in tostring(stdout or ""):gmatch("[^\r\n]+") do
    if line == CONN then
      return true
    end
  end
  return false
end

local function refresh()
  local token = generation
  noctalia.runAsync("nmcli -t -f NAME connection show --active", function(result)
    if token ~= generation then
      return
    end
    if result.exitCode == 0 then
      active = connectionIsUp(result.stdout)
      render()
    end
  end)
end

function onClick()
  generation = generation + 1
  local turningOn = not active
  active = turningOn
  render()

  local token = generation
  local verb = if turningOn then "up" else "down"
  noctalia.runAsync("nmcli connection " .. verb .. " " .. CONN, function(result)
    if token ~= generation then
      return
    end
    if result.exitCode ~= 0 then
      active = not turningOn
      render()
      noctalia.log(result.stderr or "nmcli failed")
    end
    refresh()
  end)
end

noctalia.setUpdateInterval(2000)

function update()
  refresh()
end

render()
refresh()
