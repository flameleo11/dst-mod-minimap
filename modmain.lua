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
import("main")
import("cmd")

--[[
modget("minimap").import("main")
modget("minimap").import("cmd")
]]
