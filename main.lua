local theta = 0
local omega = 0

function lovr.update(dt)
	omega = math.sin(lovr.timer:getTime())
	theta = theta + omega * dt
end

function lovr.draw(pass)
	pass:cube(0, 0.85, -3, nil, theta, nil, nil, nil, "line")

	return false
end