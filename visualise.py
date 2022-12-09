import math
import pygame as py
import os

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
    "bot!" : (255, 0, 0),
    "air" : (255, 255, 255),
    "minecraft:deepslate" : (10, 10, 10),
    "minecraft:water" : (100, 100, 255), 
}

# draw a slice of the world at layer y
# draw white where there is no block, and black where there is a block
def draw_world(world, screen, layer):
    # loop through every block in the world
    for (x, y, z), block in world.items():
        if y != layer:
            continue
        # draw a black square where there is a block
        # the block is 10x10 pixels
        # the origin is at the top left of the screen
        color = (25,25,25)
        if block in color_map:
            color = color_map[block]
        elif "ore" in block:
            # silver color
            color = (192, 192, 192)
        py.draw.rect(screen, color, (x * 10, z * 10, 10, 10))


world = read_world("world.txt")
# initialise pygame
py.init()
# create a screen
screen = py.display.set_mode((1000, 1000))

# clear the screen (white)
screen.fill((100, 100, 100))


layer = -8

# wait for the user to close the window
while True:
    for event in py.event.get():
        if event.type == py.QUIT:
            py.quit()
            exit()
        # if the user presses the up arrow, increment the layer
        if event.type == py.KEYDOWN:
            if event.key == py.K_UP:
                layer += 1
                print(layer)
            # if the user presses the down arrow, decrement the layer
            if event.key == py.K_DOWN:
                layer -= 1
                print(layer)
    # clear the screen
    screen.fill((100, 100, 100))
    # draw the world
    draw_world(world, screen, layer)
    # update the screen
    py.display.update()

        