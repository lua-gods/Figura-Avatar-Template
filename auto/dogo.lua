local Familiar = require("lib.familiarsAPI")

for i = 1, 10, 1 do
	local Cer = Familiar.new(models.models.dogo)
		 :setPositionResponse(1.5, 0.3, 0)
		 :setRotationResponse(1.5, 0.75, 0)
		 :setLocalOrientation(false)
		 :setLookAtMovementStrength(1)

	local pos = vec(
		math.random() - 0.5,
		math.random() - 0.5,
		math.random() - 0.5
	) * 5
	Cer:setPos(pos)
	
	events.TICK:register(function ()
		local shake = vec(
			math.random() - 0.5,
			math.random() - 0.5,
			math.random() - 0.5
		) * 1
		Cer:setPos((Cer:getPos() + shake):clampLength(0,10))
	end)
end
