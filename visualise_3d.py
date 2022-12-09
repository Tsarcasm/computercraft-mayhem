import math
import os
from vpython import *

# world.txt contains a list of block positions and block contents in the format
# x,y,z block
# 85,-2,26 minecraft:deepslate


# return a dictionary of (x, y, z) tuples to block names
def read_world(path):
    world = {}
    with open(path, "r") as f:
        # line by line
        for line in f:
            # split the line into a list of strings
            line = line.split()
            xyz = line[0].split(",")
            # convert the first three strings to integers
            x = int(xyz[0])
            y = int(xyz[1])
            z = int(xyz[2])
            # the block name is the last string
            block = line[1]
            # add the block to the dictionary
            world[(x, y, z)] = block
    return world


color_map = {
    "bot!" : vec(255, 0, 0),
    "air" : vec(255, 255, 255),
    "minecraft:deepslate" : vec(10, 10, 10),
}


def draw_world_3d(world):
    # world center: 84,-5,25
    center = vec(84,-5,25)
    # loop through every block in the world
    for (x, y, z), block in world.items():
        # get the color of the block from the color map
        color = color_map.get(block, vec(25, 25, 25))
        color /= 255
        print(color)
        # create a VPython box at the block's position with the specified color, offset by the world center
        box(pos=vec(x, y, z) - center, color=color, opacity=0.5)



world = read_world("world.txt")

# create a VPython canvas
canvas = canvas(title="Minecraft World")
# canvas background is a light blue
canvas.background = color.cyan

draw_world_3d(world)

# handle events
while True:
    rate(60)

    # close the program if the user clicks the close button
    if scene.kb.keys:
        key = scene.kb.getkey()
        if key == "escape":
            exit()
    pass