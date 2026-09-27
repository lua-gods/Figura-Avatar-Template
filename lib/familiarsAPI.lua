--[[______   __
  / ____/ | / / Name: GN FAMILIARS LIBRARY v1.0.0
 / / __/  |/ /  Desc: a library for making familiars
/ /_/ / /|  / Author: GNanimates | https://gnon.top | @gn68s
\____/_/ |_/ License: Mozilla Public License Version 2.0
--────────-< DEPENDENCIES >-────────--
Place required dependencies in the same folder as this script.
- DEPENDENCY > LINK
]]

local Spring = require("./GNSpring") ---@type SpringAPI
local GNcommon = require("./GNcommon") ---@type GNCommon

local UP = vec(0,1,0)

local FAMILIAR_WORLD = models:newPart("FamiliarWorld","WORLD")
:scale(16,16,16)

---@class Familiar
---@field age integer
---@field id integer
---@field host string
---
---@field offPos Vector3
---@field offRot number
---@field localOrientation boolean
---@field lookAtMovement number
---@field springPos GN.Spring<Vector3>
---@field springRot GN.Spring<number>
---@field size Vector2
---
---@field model ModelPart?
---
---@field package root ModelPart?
---@field package lpos Vector3
---@field package lrot Vector2
local Familiar = {}
Familiar.__index = Familiar

--──── Utils ────────────────────────────────────────────--
local function packUUID(uuid)
	uuid = uuid:gsub("-", "")
	local newUuid = ""
	for i = 1, 32, 2 do
		newUuid = newUuid .. string.char(tonumber(uuid:sub(i, i + 1), 16))
	end
	return newUuid
end

local uuidDashes = { [4] = true, [6] = true, [8] = true, [10] = true }
local function unpackUUID(uuid)
	local newUuid = ""
	for i = 1, 16 do
		newUuid = newUuid .. string.format("%02x", string.byte(uuid:sub(i, i)))
		if uuidDashes[i] then newUuid = newUuid .. "-" end
	end
	return newUuid
end

local function snap(value,step)
	return math.floor(value / step) * step
end

--────  ────────────────────────────────────────────--

---@class FamiliarAPI
local FamiliarAPI = {}

---@type Familiar[]
local familiars = {}

---@return Familiar
function FamiliarAPI.new(model)
	local id = #familiars + 1
	
	local root = FAMILIAR_WORLD:newPart("familiar"..id)
	root:scale(1/16,1/16,1/16)
	
	local self = {
		id = id,
		age = 0,
		
		offPos = vec(0,1,1),
		offRot = 0,
		lookAtMovement = 1,
		springPos = Spring.newVec3(),
		springRot = Spring.new(),
		
		size = vec(0,0),
		root = root
	}
	setmetatable(self,Familiar)
	familiars[id] = self
	
	if model then
		self:setModel(model)
	end
	return self
end


---Sets the model being displayed for this Familiar,
---***
---note: this copies the model and hides the original, meaning you can pass the same model again on another Familiar
---@param model ModelPart
function Familiar:setModel(model)
	if self.model then
		self.model:remove()
	end
	if model then
		local copy = model:copy("familiar"..self.id):setVisible(true)
		copy:moveTo(self.root)
		
		model:setVisible(false)
		
		self.model = copy
	end
end

---Sets the position behavior of the spring used
---@param responseSpeed Vector3|number
---@param dampingCoeficient Vector3|number
---@param initialResponseStrength Vector3|number
---@return Familiar
function Familiar:setPositionResponse(responseSpeed, dampingCoeficient, initialResponseStrength)
	self.springPos:setResponse(responseSpeed, dampingCoeficient, initialResponseStrength)
	return self
end

---Sets the offset position from the host
---@param x number
---@param y number
---@param z number
---@overload fun(self: Familiar, xyz: Vector3): Familiar
---@return Familiar
function Familiar:setPos(x,y,z)
	local pos = GNcommon.vec3(x,y,z)
	self.offPos = pos
	return self
end


---Returns the offset position from the host
---@return Vector3
function Familiar:getPos()
	return self.offPos
end

---Sets the target rotation
function Familiar:setRot(angle)
	self.offRot = angle
	return self
end

---Returns the target rotation
---@return number
function Familiar:getRot()
	return self.offRot
end

---sets the strength of which the Familiar will look towards the direction of its movement.
---
---in the range of [`0` - `1`], where `0` is none and `1` is instant
---@param lookStrength number
---@return Familiar
function Familiar:setLookAtMovementStrength(lookStrength)
	self.lookAtMovement = math.clamp(lookStrength or 1,0,1)
	return self
end

---Sets the rotation behavior of the spring used
---@param responseSpeed Vector2|number
---@param dampingCoeficient Vector2|number
---@param initialResponseStrength Vector2|number
---@return Familiar
function Familiar:setRotationResponse(responseSpeed, dampingCoeficient, initialResponseStrength)
	self.springRot
	:setResponse(responseSpeed, dampingCoeficient, initialResponseStrength,360)
	return self
end

--- sets if the position and rotation of the Familiar to be local to the host's orientation
---@param isLocal boolean
---@return Familiar
function Familiar:setLocalOrientation(isLocal)
	self.localOrientation = isLocal
	return self
end

events.TICK:register(function ()
	for index, f in pairs(familiars) do
		local host = f.host and world.getEntity(f.host) or player
		---@cast host Entity
		local rot = -host:getRot().y
		f.age = f.age + 1
		if host and host:isLoaded() then
			local pos = host:getPos()
			local vel = f.springPos.vel
			
			local lookRot = math.deg(math.atan2(vel.x,vel.z))-180
			local diff = ((lookRot - f.offRot) + 180) % 360 - 180
			f.offRot = f.offRot + diff * math.min(vel.xz:lengthSquared(),1)
			
			local offPos = f.offPos
			local offRot = f.offRot
			if f.localOrientation then
				offPos = vectors.rotateAroundAxis(rot,offPos,UP)
				offRot = offRot + rot
			end
			
			f.springPos:setTarget(pos + offPos)
			f.springRot:setTarget(offRot)
		end
	end
end)

events.RENDER:register(function (dt)
	for index, f in pairs(familiars) do
		if f.root then
			f.root
			:setPos(f.springPos:samplePos(dt))
			:setRot(0,f.springRot:samplePos(dt))
		end
	end
end)


return FamiliarAPI