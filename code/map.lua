-- This class defines named points on a map
-- Map names to positions with a hashmap / dictionary
Map = {
    map = {},

    -- Add a point to the map
    add_point = function(self, name, x, y, z)
        self.map[name] = {x = x, y = y, z = z}
    end,

    get_points = function(self)
        return self.map.keys()
    end,

    -- Get the position of a point
    get = function(self, name)
        return self.map[name].x, self.map[name].y, self.map[name].z
    end,

    serialize = function(self)
        -- write to map.txt
        -- point per line, format: name x y z
        local file = io.open("map.txt", "w")
        if (not file) then
            print("Failed to open map.txt")
            return
        end
        for k, v in pairs(self.map) do
            file:write(k .. " " .. v.x .. " " .. v.y .. " " .. v.z .. "\r\n")
        end
    end,

    deserialize = function(self)
        -- load map from file
        -- if file does not exist, create it
        -- format: a line per point, name x y z
        local file = io.open("map.txt", "r")
        if file then
            print("map.txt exists, loading map")
            for line in file:lines() do
                local name, x, y, z = line:match("([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+)")
                self:add_point(name, tonumber(x), tonumber(y), tonumber(z))
            end
            file:close()
        else
            print("No map.txt exists, creating one")
            file = io.open("map.txt", "w")
            if (not file) then
                print("Failed to create map.txt")
                return
            end
            file:close()
        end
    end,

}