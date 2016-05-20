--[[
	This file specifies a class defining 'jason', the adaptive creature of the simulation.
		It handles the drawing, collision detection, and velocity of jason,
			in addition to linking the 'body' to the 'mind'. it gets the nearest food to jason,
			and sends that information to the neural network 'brain', and then applies the output to jason's velocity.
	
	NOTE 20160520: the collision detection and food sensing in this file both have O(s*j), where s are #soylents, and j are #jasons.
					this is obviously rubbish, so if I were to do it again AND the cost of poor performance outwieghed the cost of implementation,
					I would use fortunes algorithm to sweep the soylents and update a developing voronoi diagram with the soylents as the sites.
					see the readme for more details
	
	Written by: Andrew Eric Zane
	License: MIT License, see LICENSE file in this repo.
--]]

indFuncs = require "IndFuncs"
Net = require "NeuralNet"

Jason = {x=200, y=150, detectionRadius=500, consumptionRadius=25, maxThrust=.1, calorieBurn = .007,
			reproLevel=1000, belly=800,
			reproCost=.6, rightImage=love.graphics.newImage("rally_cap_right.png"), leftImage=love.graphics.newImage("rally_cap_left.png"),
			imgSpec=.15, drawRight=true}

	function Jason:new (o)
		local o = o or {}
		setmetatable(o, self)
		self.__index = self
		--create brain in returned table, use passed brain, else, create a new brain.
		o.brain = o.brain or Net:new({spec={2, 4, 6, 4}})
		return o
	end
	
	function Jason:sense_nearest_food(foodsTable)
		--For simplicity's sake, Jason can only detect the nearest food within his radius.
		--Jason's two inputs are the x/y distance as a percentage of his detection radius.
		--(dist formula to food)/(detectionRadius) * x/y vals = sensor input
		--the sensor input
		--return the actual x and y values of nearest food.
		
		if (not foodsTable) or (#foodsTable < 1) then
			return nil
		end
		
		
		--get nearest food, foodsTable = {{5, 6}, {300, 150}}
		--	foodsTable is the absolute x and y values, {x, y}
		local foodDists = {}
		for i=1, #foodsTable do
			--[[print("X: " .. tostring(foodsTable[i].x))
			print("Y: " .. tostring(foodsTable[i].y))
			print()]]
			foodDists[i] = (indFuncs.distance({foodsTable[i].x, foodsTable[i].y}, {self.x, self.y}))/self.detectionRadius
		end
		
		local nearestIndex, nearestDist = indFuncs.min_index(foodDists)
		
		if nearestDist <= 1 then
			--if the nearest food is within detectionRadius
			--set inputs to xval/detrad yval/detrad
			self.brain:input_table({(foodsTable[nearestIndex].x-self.x)/self.detectionRadius,
									(foodsTable[nearestIndex].y-self.y)/self.detectionRadius})
									
			--if the normalized nearestDist is within the normalized consumption radius, return the index of the food object
			--	to be eaten.
			--FIXME this should probably be in it's own function? even though it's small?
			if nearestDist <= (self.consumptionRadius/self.detectionRadius) then
				return nearestIndex
			else
				--otherwise, return nothing.
				return nil
			end
		else
			return nil
		end
		
	end
	
	function Jason:consume_food(foodsTable, indexToEat)
		--if nearest food is in collision box, add it to Jason's belly.
		
		if indexToEat then
			self.belly = self.belly + foodsTable[indexToEat].pleasure
			--TODO foodsTable[indexToEat].garbage_collection()?
			table.remove(foodsTable, indexToEat)
		end
		
		
	end
	
	function Jason:thrusters(envSpeed)
		--When jason runs his thrusters, TODO he uses a small amount of food energy
		--Jason's thrusters are based on the output of his neural network
		--Thruster info is run through the collision detection function.
			
		local thrusterTable = self.brain:output_table()
		--[[print("Thruster Table:")
		print(thrusterTable[1])
		print(thrusterTable[2])
		print(thrusterTable[3])
		print(thrusterTable[4])
		print()]]
		
		--use food to thrust
		for i=1, #thrusterTable do
			--multiply thrusters by envSpeed. this percolates through the rest of the update.
			thrusterTable[i] = thrusterTable[i]*envSpeed
			self.belly = self.belly - (math.abs(thrusterTable[i])*self.calorieBurn)
		end
		
		return {thrusterTable[1]*self.maxThrust - thrusterTable[2]*self.maxThrust,
				thrusterTable[3]*self.maxThrust - thrusterTable[4]*self.maxThrust}
	end
	
	function Jason:collision(thrustedVector)
		--If a Jason thrusts toward something impassible (like the window's edge), the thruster's thrust is nullified along
		--	that dimension.
		--TODO collision things.... : ) right now we only handle window exit collision.
		
		--FIXME should we reference the window from this function or should we get the dimensions passed to it?
		
		local destVec = {thrustedVector[1] + self.x, thrustedVector[2] + self.y}
		
		--both of these use the right image dimensions...it should match the left, so it shouldn't matter.
		if (destVec[1] > (love.graphics.getWidth() - self.imgSpec*self.rightImage:getWidth())) or (destVec[1] < 0) then
			thrustedVector[1] = 0
		end
		
		if (destVec[2] > (love.graphics.getHeight() - self.imgSpec*self.rightImage:getHeight())) or (destVec[2] < 0) then
			thrustedVector[2] = 0
		end
		
		return thrustedVector
		
	end
	
	function Jason:reproduce()
		--When jason's belly is fullish, Jason reproduces 1-10ish babies (less chance as increases)
		--using less food for each additional baby
		if self.belly >= self.reproLevel then
			local babies = {}
			for i=1, math.floor(-(2.5*(math.log(love.math.random(1, 100))))+6) do
				--create baby with a copy of the parent's brain
				babies[i] = Jason:new({x=self.x, y=self.y, brain=self.brain:copy()})
				
				--[[print("Pre-mutation baby:")
				babies[i].brain:print_net()]]
				
				--mutate baby brain
				babies[i].brain:mutate_weights()
				babies[i].brain:mutate_biases()
				
				--Start baby belly half full so they don't go cray.
				babies[i].belly = babies[i].reproLevel/3
				
				--[[print("Post-mutation baby:")
				babies[i].brain:print_net()]]
				
				self.belly = self.belly - math.floor(self.reproCost*self.belly)
				--print("Belly level: " .. tostring(self.belly))
			end
			return babies
		else
			return {}
		end
	end
	
	function Jason:draw()
		if self.drawRight then
			love.graphics.draw(self.rightImage, self.x, self.y, 0, self.imgSpec, self.imgSpec)
		else
			love.graphics.draw(self.leftImage, self.x, self.y, 0, self.imgSpec, self.imgSpec)
		end
	end
	
	function Jason:update(foodsTable, envSpeed)
		--Jason get's updated every few frames or so.
		
		--sense_nearest_food returns a food object index to be eaten, nil if none to be eaten.
		--consume_food then deletes that food object, and then removes that index from the foodsTable
		self:consume_food(foodsTable, self:sense_nearest_food(foodsTable))
		
		--TODO check if Jason is out of food/dead
		
		--	run Jason's brain to get outputs
		self.brain:run()
		
		--thrusters takese the outputs of the brain and returns a vector by which current coords are to be modified.
		--collision takes this information, accounts for adjecent impassibles, and returns a modified vector.
		--pass envSpeed to thrusters, affects speed and consumption
		local toAddX, toAddY = unpack(self:collision(self:thrusters(envSpeed)))
		--print (toAddX .. " " .. toAddY)
		self.x = self.x + toAddX
		self.y = self.y + toAddY
		
		--	draw Jason with updated xy values, if toAddX is greater than 0, pass true, the right facing image will be drawn.
		--self:draw((toAddX > 0)) called from love.draw separate from update
		self.drawRight = (toAddX > 0)
		
		--check reproductive potential, reproduce if ready, return a table of new Jason babies
		return self:reproduce()
	end
	
return Jason