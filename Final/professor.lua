
--local classic = require 'classic'
local class = require 'middleclass'
-- local Object = require "classic"

Professor = class('Professor')

-- Professor = Object:extend()

function Professor:initialize(x, y)
	self.x = x
	self.y = y
  self.counter = 0
	self.width = 10
	self.height = 10
	self.range = 100
	-- doing 1-hit missiles first
	self.missile = missile
	--Professor.timeToLive = 5
end

--[[function Professor:getX()
	return self.x
end

function Professor:getY()
	return self.y
end]]--

function Professor:update(distance, dt)
	if distance < self.range then
		-- fire missile
		local startX = self.x + self.width / 2
		local startY = self.y + self.height / 2
		local angle = math.atan2(xdistance, ydistance)
		local DX = 10 * math.cos(angle)
		local DY = 10 * math.sin(angle)
		local mMissile = missile:new(cx, cy, DX, DY)
		table.insert(missiles, mMissile)
	end

	-- missile either despawns or we let it fly off the board

	--[[ despawn after some time
	self.timeToLive = self.timeToLive - dt
	if self.timeToLive < 0 then
		self.to_delete = true
	end]]--


end
