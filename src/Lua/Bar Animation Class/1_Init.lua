local bartable = {}

PTAnimFunctions.NewBar = function(tag, x, y, name, width, height)
	local bar = {}
	if not (tag and x ~= nil and y ~= nil and name and width) return end
	if bartable[tag] bartable[tag] = nil end

	bar.offsetx = 0
	bar.width = width/2
	bar.height = height
	bar.name = name

	bartable[tag] = bar
end

PTAnimFunctions.GetBar = function(tag)
	return bartable[tag]
end

addHook('ThinkFrame', function()
	for _,self in pairs(bartable)
		// print('offset time'..barOffset, 'length shit'..(length/bar.width))
	end
end)

PTAnimFunctions.DrawBar = function(v, tag, x, y, scale, length, flags, color)
	local bar = bartable[tag]
	if not bartable[tag] return end
	local patch = v.cachePatch(bar.name)
	local truelength = FixedMul(length, scale)
	local barOffset = (((-leveltime)%bar.width)+bar.width)%bar.width
	local width = min(truelength, FixedMul(bar.width*FU, scale))
	v.drawCropped(x, y, scale, scale, patch, flags or 0, color, barOffset, 0, width, bar.width*FU, bar.height*FU)
end