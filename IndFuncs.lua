--[[
	This file specifies a number of helper functions used throughout this project.
	Written by: Andrew Eric Zane
	License: MIT license, see LICENSE file in this repo.
--]]

local funcs = {}

funcs.number_string = function (number, base, w)
	--source: http://lua-users.org/lists/lua-l/2002-10/msg00245.html
	--updated with string.funcs, replaced mod() with %, added w
	local digits = {}
	for i=0,9 do digits[i] = string.char(string.byte('0')+i) end
	for i=10,36 do digits[i] = string.char(string.byte('A')+i-10) end
	local s = ""
	repeat
		local remainder = number % base
		s = digits[remainder]..s
		number = (number-remainder)/base
	until number==0
	
	if w then
		return string.format("%0".. w .."s", s)
	else
		return s
	end
end

funcs.sigmoid = function (x, coefficients)
	--flexible sigmoid function
	--coefficients = {xRange = _, yRange = _, xCen = _, yCen = _}
	
	--defaults create a 1-1 square sigmoid.
	coefficients.yRange = coefficients.yRange or 1
	coefficients.xRange = coefficients.xRange or 1
	
	s = (coefficients.yRange*1.5)/coefficients.xRange --s: slope at sigmoid center
	p = coefficients.yRange/2 --p: in either direction, distance to sigmoid limit
	t = coefficients.xCen or .5--t: y value of sigmoid center
	d = coefficients.yCen or .5--d: x value of sigmoid center
	
	local c = 10^(s/p)
	return (((2*p)/(1+c^(d-x)))+t-p)
	
end

funcs.distance = function (dims1, dims2)
	if #dims1 == #dims2 then
		local toSqrt = 0
		for i=1, #dims1 do
			toSqrt = toSqrt + ((dims1[i] - dims2[i])^2)
		end
		return toSqrt^(.5)
	else
		error"Cannot calculate distance between points with different numbers of dimensions."
	end
end

funcs.min_index = function (t)
	local key, min = 1, t[1]
	for k, v in ipairs(t) do
	    if v < min then
	        key, min = k, v
	    end
	end
	return key, min
end

funcs.extend_table = function (t, ...)
	for k, v in pairs({...}) do
		table.insert(t, v)
	end
end

return funcs