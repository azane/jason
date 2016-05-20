--[[
This file contains the food object Soylent. This object looks like 
	vegemite and moves around in a randomish pattern.
Written by: Kilen Multop
License: MIT License, see LICENSE file in this repo.
--]]

--[[
Description of Soylent:

Soylent has the following parameters/members:
x - x coordinate value
y - y coordinate value
pleasure - an inherited value, not used by Soylent
persistence - used with speedx & speedy to determine movement. Persistence determines how long soylent moves in a particular direction
speedx - the x distance moved each update. Can be any value between -1 and 1
speedy - the y distance moved each update. Can be any value between -1 and 1
--]]
Soylent = {x = 500, y = 500, pleasure = 50, persistence = 100, speedx = .1, speedy = 0.1,
			vegemite=love.graphics.newImage("Vegemite-Jar-2013.jpg"), imgSpec = 1}

--Constuctor for the Soylent class
	function Soylent:new (o)

		--if given a table, use it, otherwise assign an empty table to o
		local o = o or {}
		--set the metatable given o
		setmetatable(o, self)
		self.__index = self
		return o

	end
	
	function Soylent:loiter (envSpeed)
			
			--the next four lines reset direction, speed and distance whenever persistence gets low
		if (self.persistence < 1)then
			self.persistence = love.math.random(50,200)
			self.speedx = (love.math.random(-10,10))/10
			self.speedy = (love.math.random(-10,10))/10
		
		else
			--double check we aren't running into the window wall
			if((self.x + 1) >= love.graphics.getWidth() or (self.x - 1) < 1)then
				--go in opposite direction if you hit the wall
				self.speedx = -(self.speedx)
			end
			--double check we aren't running into the window wall
			if((self.y + 1) >= love.graphics.getHeight() or (self.y - 1) < 1)then
				--go in opposite direction if you hit the wall
				self.speedy = -(self.speedy)
			end
			--decrement persistence every time self moves
			self.persistence = self.persistence - 1*envSpeed
			--move x for speedx and y for speedy, multiply by environment speed.
			self.x = self.x + (self.speedx*envSpeed)
			self.y = self.y + (self.speedy*envSpeed)
		end
	end

	function Soylent:draw ()	
		--get the image from local directory, then draw it with our current x and y values
		love.graphics.draw(self.vegemite, self.x, self.y, 0, self.imgSpec, self.imgSpec)

	end


return Soylent