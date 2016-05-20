--[[
	This is the main file required by love2d to run, it contains love specific functions referencing the rest of the program.
	Written by: Andrew Eric Zane
	License: MIT license, see LICENSE file in this repo.
--]]

indFuncs = require "IndFuncs"
matrix = require "matrix"
complex = require "complex"
net = require "NeuralNet"
Jason = require "Jason"
Soylent = require "Food"

function love.load()
	--This happens on window init
	
	love.window.setMode(5000, 700)
	
	doDraw = true --this determines if things are actually drawn on the screen.
	
	jasonTable = {}
	for i=1, 300 do
		--print("Creating a jason!")
		jasonTable[i] = Jason:new({x=love.math.random(love.graphics.getWidth()-Jason.rightImage:getWidth()*Jason.imgSpec),
									y=love.math.random(love.graphics.getHeight()-Jason.rightImage:getWidth()*Jason.imgSpec)})
		jasonTable[i].brain:rand_weights()
		jasonTable[i].brain:rand_biases()
	end
	--jasonTable[1].brain:print_net()
	
	foodsTable = {}
	for i=1, 600 do
		table.insert(foodsTable, Soylent:new({x=love.math.random(love.graphics.getWidth()-Soylent.vegemite:getWidth()*Soylent.imgSpec),
												y=love.math.random(love.graphics.getHeight()-Soylent.vegemite:getWidth()*Soylent.imgSpec)}))
	end
	foodRepRate = .4
	foodTimer = 0
	
	speed = 30
	foodSpeed = .01
end

function love.keypressed(key)
	if key == "return" then
		doDraw = (not doDraw)
	end
	
	if key == "up" then
		speed = speed + 1
		print("Env Speed" .. tostring(speed))
	elseif key == "down" then
		speed = speed - 1	
		print("Env Speed" .. tostring(speed))
	end
	
	if key == "right" then
		foodSpeed = foodSpeed + .01
		print("Food Speed" .. tostring(foodSpeed))
	elseif key == "left" then
		foodSpeed = foodSpeed - .01
		print("Food Speed" .. tostring(foodSpeed))
	end
end

function love.update(dt)
	--This happens every frame
	foodTimer = foodTimer + (dt*speed)
	--print(foodTimer)
	
	if foodTimer > foodRepRate then
		table.insert(foodsTable, Soylent:new({x=love.math.random(love.graphics.getWidth()-Soylent.vegemite:getWidth()*Soylent.imgSpec),
												y=love.math.random(love.graphics.getHeight()-Soylent.vegemite:getWidth()*Soylent.imgSpec)}))
		foodTimer = 0
	end
	
	for i=1, #foodsTable do
		foodsTable[i]:loiter((foodSpeed*speed))
	end
	
	local babies = {}
	local deadJasonIndices = {}
	for i=1, #jasonTable do
		indFuncs.extend_table(babies, unpack(jasonTable[i]:update(foodsTable, speed)))
		--check if jason starved
		if jasonTable[i].belly <= 0 then
			indFuncs.extend_table(deadJasonIndices, i)
		end
	end
	
	for i=1, #deadJasonIndices do
		table.remove(jasonTable, deadJasonIndices[i])
	end
	
	indFuncs.extend_table(jasonTable, unpack(babies))
	
end

function love.draw()
	
	if not doDraw then
		return
	end
	
	--draw all the foods
	for i=1, #foodsTable do
		foodsTable[i]:draw()
	end
	
	--draw all the jasons
	for i=1, #jasonTable do
		jasonTable[i]:draw()
	end
end