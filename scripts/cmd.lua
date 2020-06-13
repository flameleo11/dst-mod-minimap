------------------------------------------------------------
-- header
------------------------------------------------------------

local require = GLOBAL.require
local modinit = require("modinit")
modinit("minimap")

------------------------------------------------------------
-- main
------------------------------------------------------------

require("tprint")

this = this or {}
this.selected_ents = this.selected_ents or {}
this.color = {x = 1, y = 1, z = 1}

------------------------------------------------------------
-- utils
------------------------------------------------------------

function split_by_space(s)
  local arr = {}
  for w in s:gmatch("%S+") do
    arr[#arr+1] = w
  end
  return arr
end

------------------------------------------------------------
-- common
------------------------------------------------------------

function IsInGameplay()
  if not ThePlayer then
    return
  end
  if not (TheFrontEnd:GetActiveScreen().name == "HUD") then
    return
  end
  return true
end

function IsDST()
  return TheSim:GetGameID() == "DST"
end

function _AddThePlayerInit(fn)
  if IsDST() then
    env.AddPrefabPostInit("world", function(wrld)
      wrld:ListenForEvent("playeractivated", function(wlrd, player)
        if player == ThePlayer then
          fn()
        end
      end)
    end)
  else
    env.AddPlayerPostInit(function(player)
      fn()
    end)
  end
end


function init_hotkey()
  -- cfg_toggle_key     = GetModConfigData("TOGGLE_KEY")
  local cfg_toggle_key = "M"
  if not (cfg_toggle_key == "None") then
    local keybind = _G["KEY_"..cfg_toggle_key]
    TheInput:AddKeyDownHandler(keybind, function ()
      onPressToggleKey()
    end)
  end
end


function set_mapscale(minimap_small, mapscale)
  mapscale = mapscale or 1
  local bg = Image("images/hud.xml", "map.tex")
  local map_w, map_h = bg:GetSize()
  bg:Kill()
  bg = nil
  print(111, map_w, map_h)
  local map_w, map_h = map_w*mapscale, map_h*mapscale
  minimap_small.mapsize = {w=map_w, h=map_h}
  minimap_small.img:SetSize(map_w,map_h,0)
  minimap_small.bg:SetSize(0,0,0)
  print(222, map_w, map_h)
end

------------------------------------------------------------
-- func
------------------------------------------------------------

onPressToggleKey = _f(function ()
	print("..minimap...............onPressToggleKey.,,,,,")
  if not IsInGameplay() then return end

  local map = this.controls.minimap_small
  map:ToggleOpen()

  print("-------------------------------->>>>>>>>>>")
  for k,v in pairs(package._cache) do
    print(k,v)
  end
  print("<<<<<<<<<<<<-------------------------------")
end)



onThePlayerInit = _f(function ()
  if not (this.hotkey_inited) then
  	init_hotkey()
  	this.hotkey_inited = true
  end

  -- todo timeouttask 0
  ThePlayer:DoTaskInTime(0, function()
    on_minimap()
  end, 0)
end)

on_minimap = _f(function (params, caller)
  -- show_msg("test ...... ok...111")
  local args = {}
  if (params and params.rest and #params.rest > 0) then
    args = split_by_space(params.rest)
  end

  local map = this.controls.minimap_small
  local bgEnable = args[1] and true or false
  local zoomEnable = args[2] and true or false
  local mapscale = args[3] and tonumber(args[3]) or 0.4
  local ups = args[4] and tonumber(args[4]) or 0.5
  local pos = map:GetPosition()
  x = args[5] and tonumber(args[5]) or -320
  y = args[6] and tonumber(args[6]) or -600

  print(555, bgEnable, map.bgEnable)
  if not (bgEnable == map.bgEnable) then
  	map:ToggleBG(bgEnable)
  print(666, bgEnable, map.bgEnable)
  	map:ToggleOpen()
	  ThePlayer:DoTaskInTime(0, function()
	    map:ToggleOpen()
		  ThePlayer:DoTaskInTime(0, function()
		    map:ToggleOpen()
		  end, 0)
	  end, 0)
  end

  map.img:SetClickable(zoomEnable)
  map:SetUPS(ups)
  -- map:ToggleOpen()
  map:SetOpen(true)

  set_mapscale(map, mapscale)

  map:SetPosition(x, y)
  print(998, x, y, mapscale, ups)
end)

AddUserCommand("minimap", {
  prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.BUG.PRETTYNAME
  desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.BUG.DESC
  permission = COMMAND_PERMISSION.USER,
  slash = false,
  usermenu = false,
  servermenu = false,
  params = {},
  vote = false,
  localfn = function(params, caller)
    on_minimap(params, caller)
  end,
})

_AddThePlayerInit(function ()
  onThePlayerInit()
end)


if (TheInput and ThePlayer) then
  onThePlayerInit()
end


------------------------------------------------------------
-- cache controls
------------------------------------------------------------

onCreateControls = _f(function (self)
  print("......onCreateControls", self)
  this.controls = self
end)
AddClassPostConstruct("widgets/controls", onCreateControls)

-- hide default map icons
onCreateMapControls = _f(function (self)
  self:RemoveChild(self.minimapBtn)
  self:RemoveChild(self.pauseBtn)
  self:RemoveChild(self.rotleft)
  self:RemoveChild(self.rotright)

  this.mapcontrols = self
end)

AddClassPostConstruct("widgets/mapcontrols", onCreateMapControls)


print("init................998")
--[[
modget("minimap").import("cmd")
modget("autofish").import("main")
print(modget("autofish").ver)

modget("minimap").this
  local map = this.controls.minimap_small
  map:ToggleOpen()
]]