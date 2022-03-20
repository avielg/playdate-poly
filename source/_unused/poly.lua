--- Constructs a regular polygon
--- Description:
-- Counter-clockwise where the first vertex is: 1*r, 0
--- Parameters:
-- @param n Number of sides
-- @param r Circumradius
-- @return Regular polygon
function polyRegular(n, r, out)
	local pi2 = 2 * math.asin(1.0)
	out = out or {}
	local i = 1
	for j = 1, n do
		local a = j/n*pi2
		local r2 = math.random()--*0.5 + 0.5 -- random number in range [0.5-1]
		out[i] = math.cos(a)*r*r2
		out[i + 1] = math.sin(a)*r*r2
		i = i + 2
	end
	return out
end

--- Constructs a regular polygon
-- @param n Number of sides
-- @param s Side
-- @return Regular polygon
function polyRegular2(n, s, out)
	local r = s/(2*math.sin(math.pi/n))
	return polyRegular(n, r, out)
end