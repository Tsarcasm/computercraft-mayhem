require("map")
require("secrets")
-- Deadreckoning class
-- This class is used to keep track of the turtle's position and orientation
-- This class provides a movement api so we can keep track of the turtle's position as it changes
-- This class also provides a way to move the turtle to a specific position


DeadReckoning = {
    x = 0,
    y = 0,
    z = 0,
    direction = 0, -- n=0 e=1 s=2 w=3
    should_break = false,
    -- north-south is -ve z to +ve z
    -- west-east is -ve x to +ve x

    --[[ 

                    north  z = 0

        x = 0 west        east x = 5
                
                   south  z = 5

     ]]

    -- get the direction vector
    get_direction_vector = function(self)
        if self.direction == 0 then
            return 0, 0, -1
        elseif self.direction == 1 then
            return 1, 0, 0
        elseif self.direction == 2 then
            return 0, 0, 1
        elseif self.direction == 3 then
            return -1, 0, 0
        end
    end,

    get_position = function(self)
        return self.x, self.y, self.z
    end,

    get_facing_coordinates = function(self)
        local dx, dy, dz = self:get_direction_vector()
        return self.x + dx, self.y + dy, self.z + dz
    end,

    print_position = function(self)
        print("x: " .. self.x .. " y: " .. self.y .. " z: " .. self.z)
    end,


    set_break = function(self, should_break)
        self.should_break = should_break
    end,


    move_forward = function(self, n, func)
        for i = 1, n do
            while true do

                local dug = false
                if self.should_break then
                    dug = turtle.dig()
                end

                local moved = turtle.forward()
                if moved then
                    break
                else
                    print("Failed to move forward")
                    if dug then
                        -- we dug but didn't move, so could be a gravity block?
                        -- try again
                    else
                        return i - 1
                    end

                end
            end
            local dx, dy, dz = self:get_direction_vector()
            self.x = self.x + dx
            self.y = self.y + dy -- should never change
            self.z = self.z + dz
            if func then func(self) end
        end
        return n
    end,

    move_up = function(self, n, func)
        for i = 1, n do
            if self.should_break then
                turtle.digUp()
            end

            local moved = turtle.up()
            if not moved then
                print("Failed to move up")
                return i - 1
            end
            self.y = self.y + 1
            if func then func(self) end
        end
        return n
    end,

    move_down = function(self, n, func)
        for i = 1, n do
            if self.should_break then
                turtle.digDown()
            end
            local moved = turtle.down()
            if not moved then
                print("Failed to move down")
                return i - 1
            end
            self.y = self.y - 1
            if func then func(self) end
        end
        return n
    end,

    turn = function(self, rot)
        if rot == -1 then
            turtle.turnLeft()
            self.direction = (self.direction - 1) % 4
        elseif rot == 1 then
            turtle.turnRight()
            self.direction = (self.direction + 1) % 4
        end
    end,

    set_facing = function(self, direction)
        local rot = direction - self.direction
        if rot == 0 then
            return
        elseif rot == 1 or rot == -3 then
            self:turn(1)
        elseif rot == -1 or rot == 3 then
            self:turn(-1)
        elseif rot == 2 or rot == -2 then
            self:turn(1)
            self:turn(1)
        end
    end,


    -- move to a specific position
    -- move x then z then y
    -- return the final position (x, y, z) if success or failed
    -- optionally, run a function after each move
    move_to = function(self, x, y, z, func)
        print("Moving to: x=" .. x .. " y=" .. y .. " z=" .. z)
        local dx = x - self.x
        local dy = y - self.y
        local dz = z - self.z

        -- move x
        if dx > 0 then -- move east
            self:set_facing(1)
        elseif dx < 0 then -- move west
            self:set_facing(3)
        end
        self:move_forward(math.abs(dx), func)

        -- move z
        if dz > 0 then -- move south
            self:set_facing(2)
        elseif dz < 0 then -- move north
            self:set_facing(0)
        end
        self:move_forward(math.abs(dz), func)

        -- move y
        if dy > 0 then -- move up
            self:move_up(math.abs(dy), func)
        elseif dy < 0 then -- move down
            self:move_down(math.abs(dy), func)
        end

        return self:get_position()
    end,





}



-- load position from file
-- if file does not exist, create it
-- format: a line per param, x y z direction
local file = io.open("position.txt", "r")
if file then
    print("position.txt exists, loading position")
    DeadReckoning.x = tonumber(file:read())
    DeadReckoning.y = tonumber(file:read())
    DeadReckoning.z = tonumber(file:read())
    DeadReckoning.direction = tonumber(file:read())
    -- print
    DeadReckoning:print_position()
    file:close()
else
    print("No position.txt exists, creating one")
    file = io.open("position.txt", "w")
    if (not file) then
        print("Failed to create position.txt")
        return
    end
    -- set position to 0,0,0
    file:write("0 0 0 0")
    file:close()
end



Map:deserialize()

DeadReckoning:set_break(true)

local function save_world(world)
    -- save world to world.txt
    file = io.open("world.txt", "w")
    if (file) then
        for k, v in pairs(world) do
            file:write(k .. " " .. v .. "\r\n")
        end
        file:close()
    else
        print("Failed to open world.txt")
    end

    -- save world to web api
    local str = ""
    for k, v in pairs(world) do
        str = str .. k .. " " .. v .. "\r\n"
    end
    print(str)
    local headers = {}
    headers["Content-Type"] = "text/plain"
    local body, code, headers, status = http.request(API_URL .."/world", str, headers)

end

local world = {}

local function exists_or_air(exists, block)
    if exists then
        return block.name
    else
        return "air"
    end
end

local function log_surroundings(dr)
    -- turn 4 times
    for i = 1, 4 do
        local facing_x, facing_y, facing_z = dr:get_facing_coordinates()
        local name = exists_or_air(turtle.inspect())
        world[facing_x .. "," .. facing_y .. "," .. facing_z] = name
        dr:turn(1)
    end
    -- up
    world[dr.x .. "," .. dr.y + 1 .. "," .. dr.z] = exists_or_air(turtle.inspectUp())
    -- down
    world[dr.x .. "," .. dr.y - 1 .. "," .. dr.z] = exists_or_air(turtle.inspectDown())
    -- bot
    world[dr.x .. "," .. dr.y .. "," .. dr.z] = "bot!"

end

local base_x, base_y, base_z = Map:get("base")
local refuel_x, refuel_y, refuel_z = Map:get("refuel")
local test_x, test_y, test_z = Map:get("test")
-- DeadReckoning:move_to(base_x, base_y, base_z, log_surroundings)
-- look north
DeadReckoning:set_facing(0)

-- if there is a chest in front of us, unload all our items
if exists_or_air(turtle.inspect()) == "minecraft:chest" then
    -- loop through all inventory slots
    for i = 1, 16 do
        turtle.select(i)
        local dropped = turtle.drop()
        print("Dropped: " .. tostring(dropped))
        if not dropped then break end
    end
    turtle.select(1)
end
DeadReckoning:move_to(80, 60, 35, log_surroundings)
DeadReckoning:move_to(80, 66, 35, log_surroundings)
save_world(world)

-- -- take 1 stack of coal from the container
-- DeadReckoning:move_to(refuel_x, refuel_y, refuel_z)
-- DeadReckoning:set_facing(0)
-- turtle.select(1)
-- turtle.suck(64)

-- -- refuel
-- turtle.refuel(64)


-- print fuel level
-- print("Fuel level: " .. turtle.getFuelLevel())





-- DeadReckoning:move_to(70, 10, 50, log_surroundings)

-- at y=-10 strip mine
-- mine 10 blocks in a direction, turn 90 degrees, mine 5 blocks, turn 90 degrees, mine 10 blocks
-- turn -90 degrees, mine 5 blocks, turn -90 degrees
-- for i = 1, 3 do
--     save_world(world)
--     DeadReckoning:move_forward(20, log_surroundings)
--     DeadReckoning:turn(1)
--     DeadReckoning:move_forward(5, log_surroundings)
--     DeadReckoning:turn(1)
--     DeadReckoning:move_forward(20, log_surroundings)
--     DeadReckoning:turn(-1)
--     DeadReckoning:move_forward(5, log_surroundings)
--     DeadReckoning:turn(-1)
-- end


save_world(world)

-- save position to file
file = io.open("position.txt", "w")
if (not file) then
    print("Failed to open position.txt")
    return
end
file:write(DeadReckoning.x .. "\r\n" .. DeadReckoning.y .. "\r\n" .. DeadReckoning.z .. "\r\n" .. DeadReckoning.direction)
file:close()
