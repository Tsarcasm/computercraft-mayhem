-- This is the code to be run on the mining coordinator
-- Coordinator's job is to keep track of the space to mine, and dish out mining jobs




require("Stripmine")
Mine = {
    origin_x = 0,
    origin_y = 0,
    origin_z = 0,
    origin_dir = 0,

    strips = {},

    direction_vector = function(self, rotate)
        local dir = (self.direction + rotate) % 4
        if dir == 0 then -- north
            return 0, 0, -1
        elseif dir == 1 then -- east
            return 1, 0, 0
        elseif dir == 2 then -- south
            return 0, 0, 1
        elseif dir == 3 then -- west
            return -1, 0, 0
        end
    end,

    generate_strips = function(self, num_mines, spacing, len)
        -- Generate n*2 strips, n in each direction
        for i = 1, num_mines * 2 do
            -- direction of main path
            local x, y, z = self.direction_vector(0)
            x = x * spacing * i
            y = y * spacing * i
            z = z * spacing * i

            -- if even then start to the left, otherwise start to the right
            local dn = 1
            if i % 2 == 0 then dn = -1 end
            local dx, dy, dz = self.direction_vector(dn)
            self.strips[i] = StripClass:new(x + dx, y + dy, z + dz, (self.origin_dir + dn) % 4, len)
        end
    end,

    -- Specific points for bots in the mine
    -- Mine entrance: the start position of the central strip.
    -- Bots should go here, then travel to their designated strip

    -- Mine exit: one block higher than the entrance.
    -- Returning bots should go up before they join the return strip
    -- This prevents bots from meeting eachother as they travel / return

    get_entrance = function(self)
        return self.origin_x, self.origin_y, self.origin_z
    end,

    get_exit = function(self)
        return self.origin_x, self.origin_y + 1, self.origin_z
    end,




}



-- Look for a turtle next to the base station
local turtle = peripheral.find("turtle")
if turtle == nil then
    return
end

-- Get the turtle ID
local turtleID = turtle.getID()
print("Found turtle with ID " .. turtleID)
