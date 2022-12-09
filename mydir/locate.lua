-- require 4 command line arguments
-- x, y, z, direction

local args = {...}
if #args ~= 4 then
    print("Usage: move <x> <y> <z> <direction>")
    return
end

local x = tonumber(args[1])
local y = tonumber(args[2])
local z = tonumber(args[3])
local direction = tonumber(args[4])




-- save position to file
local file = io.open("position.txt", "w")
if (not file) then
    print("Failed to open position.txt")
    return
end
file:write(x .. "\r\n" .. y .. "\r\n" .. z .. "\r\n" .. direction)
file:close()

