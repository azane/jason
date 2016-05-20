--[[
	This file specifies a class defining a rudimentary neural network, but only for the purpose a compact, parameterized representation of a function.
		i.e. backpropogation is not included in this version
	The class contains:
		methods to copy and initialize the network and mutate its weights.
		methods to set the values of the first layer, and to retrieve the values of the last layer
	Written by: Andrew Eric Zane
	License: MIT license, see LICENSE file in this repo.
--]]


indFuncs = require "IndFuncs"
matrix = require "matrix"

NeuralNet = {spec = {1, 3, 2}, mLimit=1, mRate=.1}

	local function create_net(o, spec)
		--not a public function, called from new
		o.layers = {}
		o.biases = {}
		o.weights = {}
	
		for l=1, #spec do
			--create a layer of size spec[l] for every layer in spec
			o.layers[l] = matrix(spec[l], 1)
		
			if (l>1) then
				--create a bias matrix for every layer beyond the first of size spec[l]
				o.biases[l] = matrix(spec[l], 1)
		
				--create a weight matrix for every layer beyond the first, of size (spec[l], spec[l-1])
				o.weights[l] = matrix(spec[l], spec[l-1])
			end
		end
	end
	
	function NeuralNet:new (o)
		local o = o or {}
		setmetatable(o, self)
		self.__index = self
		--Fun fact...if you pass "self" as the first argument, then all the neural nets reference the default network
		--	instead of the newly created object.
		create_net(o, o.spec)
		return o
	end
	
	function NeuralNet:copy()
		--FIXME there's got to be a better way to do this...
		local copy = NeuralNet:new({spec = self.spec, mLimit = self.mLimit, mRate = self.mRate})
		--self:print_net()
		for l=1, #copy.spec do
			--don't copy layers.
			--copy.layers[l] = matrix.copy(self.layers[l])
			if (l>1) then
				copy.biases[l] = matrix.copy(self.biases[l])
				--print("Bias copied! " .. tostring(l))
				--[[print("Original Weights:")
				print(self.weights[l])
				print("Unfilled Destination:")
				print(copy.weights[l])]]
				copy.weights[l] = matrix.copy(self.weights[l])
				--[[print("Copied Weights:")
				print(copy.weights[l])
				print()]]
				--print("Weight copied! " .. tostring(l))
			end
		end
		
		return copy
	end
	
	local function rand_fill(tbl, start, stop, idp)
		--not a public function
		if not tbl then
			error"Table is required."
		end
		local start = start or -100
		local stop = stop or 100
		local idp = idp or stop --default range -1 to 1
		
		--iterate every row of table indexed 2-()#tbl+1)
		for l=2, #tbl do
			matrix.random(tbl[l], start, stop, idp)
		end
		
	end
	
	function NeuralNet:rand_weights (start, stop, idp)
		rand_fill(self.weights, start, stop, idp)
	end
	
	function NeuralNet:rand_biases (start, stop, idp)
		rand_fill(self.biases, start, stop, idp)		
	end
	
	function NeuralNet:print_net ()
		for l=1, (#self.layers - 1) do
			print("Activations " .. tostring(l) .. ": ")
			matrix.print(self.layers[l])
			print()
			
			print("Weights " .. tostring(l+1) .. ": ")
			matrix.print(self.weights[l+1])
			print()
			
			print("Biases " .. tostring(l+1) .. ": ")
			matrix.print(self.biases[l+1])
			print()
		end
		
		print("Outputs " .. tostring((#self.layers)) .. ": ")
		matrix.print(self.layers[#self.layers])
		print()
	end
	
	function NeuralNet:run ()
		--TODO run through activation function...sigmoidy thing.
		for l=2, (#self.layers) do
			self.layers[l] = self.weights[l]*self.layers[l-1] + self.biases[l]
		end
	end
	
	function NeuralNet:input_table(inputTable)
		if matrix.rows(self.layers[1]) == #inputTable then
			for i=1, #inputTable do
				matrix.setelement(self.layers[1], i, 1, inputTable[i])
			end
		else
			error"#inputTable does not match the #inputLayer"
		end
	end
	
	function NeuralNet:output_table()
		local out = {}
		for i=1, #(self.layers[#self.layers]) do
			out[i] = matrix.getelement(self.layers[#self.layers], i, 1)
		end
		return out
	end
	
	local function mutate(tbl, lim, rate)
		--TODO send rate through a sigmoid or something so that major mutations are possible, but unlikely.
		--TODO have that sigmoid only allow mutations within a % (rate) of the max/min values of that which is being mutated.
		local mutMatrix = true
		lim = lim*100
		
		--biases and weights start in row 2. So start with index 2.
		for l=2, #tbl do
			mutMatrix = matrix(matrix.rows(tbl[l]), matrix.columns(tbl[l]))
			matrix.random(mutMatrix, -lim, lim, lim/rate)
			
			--[[print("mutMatrix: ")
			matrix.print(mutMatrix)
			print()
			print("tbl: ")
			matrix.print(tbl[l])
			print()]]
			
			tbl[l] = tbl[l] + mutMatrix
			
			--[[print("sum: ")
			matrix.print(tbl[l])
			print()]]
		end
	end
	
	function NeuralNet:mutate_weights(lim, rate)
		lim = lim or self.mLimit
		rate = rate or self.mRate
		mutate(self.weights, lim, rate)
	end
	
	function NeuralNet:mutate_biases(lim, rate)
		lim = lim or self.mLimit
		rate = rate or self.mRate
		mutate(self.biases, lim, rate)
	end
	
return NeuralNet