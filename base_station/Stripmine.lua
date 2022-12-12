
-- Example Stripmine object
--[[
Stripmine = {
    start_x = 0, start_y = 0, start_z = 0,
    mine_dir = 0,
    target_length = 0,
    blocks_mined = 0,

    -- Returns a boolean, true if the stripmine is complete
    isComplete = function(self) return self.blocks_mined >= self.target_length end,

    -- Set how many blocks have been mined
    setBlocksMined = function(self, num) self.blocks_mined = num end,

    -- Return a string for this stripmine in the format x,y,z,dir,target_length,blocks_mined
    str = function(self)
        return self.x .. "," .. self.y .. "," .. self.z .. ","
            .. self.mine_dir .. "," .. self.target_length .. "," .. self.blocks_mined
    end,
}
]]--

-- Make a class from the object
StripClass = {}
StripClass.__index = StripClass

function StripClass:new(x, y, z, dir, len)
    self.x = x
    self.y = y
    self.z = z
    self.mine_dir = dir
    self.target_length = len
    self.blocks_mined = 0
end

-- Returns a boolean, true if the stripmine is complete
function StripClass:isComplete() return self.blocks_mined == self.target_length end

-- Set how many blocks have been mined
function StripClass:setBlocksMined(num) self.blocks_mined = num end

-- Return a string for this stripmine in the format x,y,z,dir,target_length,blocks_mined
function StripClass:str()
    return self.x .. "," .. self.y .. "," .. self.z .. ","
        .. self.mine_dir .. "," .. self.target_length .. "," .. self.blocks_mined
end