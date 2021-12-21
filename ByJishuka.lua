local Block = require(game:GetService("ServerStorage").Block)
local Seed = math.random(1, 999999)
local Amplitude = -300
local Scale = 200
local Dimensions = {
	X = 128,
	Y = 256,
	Z = 128
}

local Size = 4

function GenChunk(StartX, StartY, StartZ, WithCaves)
	for X =  StartX, StartX + Dimensions.X, 4 do
		coroutine.wrap(function()
			for Z = StartZ, StartZ + Dimensions.Z, 4 do
				coroutine.wrap(function()
					for Y = StartY, StartY + Dimensions.Y, 4 do
						coroutine.wrap(function()
							local Height =  math.abs(math.floor(math.clamp(math.noise(X/Scale, Z/Scale, Seed),0,1) * Amplitude))
							local XNoise = math.abs(math.floor(math.clamp(math.noise(Y/Scale, Z/Scale, Seed),0,1) * Amplitude))
							local ZNoise = math.abs(math.floor(math.clamp(math.noise(X/Scale, Z/Scale, Seed),0,1) * Amplitude))
							local Density = XNoise + ZNoise + Height
							if Y - 1 == Height or Y - 2 == Height or Y - 3 == Height or Y == Height then
								Block.new(1, X, Y, Z, "Grass"):show()
							elseif Y <= Height then
								if Y == 0 then

								end
								Block.new(1, X, Y, Z, "Dirt"):show()
							end
						end)()
					end
				end)()
			end
		end)()
	end
end

for X = 0, 4, 1 do
	for Y = 0, 4, 1 do
		coroutine.wrap(function()
			GenChunk(X*Dimensions.X, 0, Y*Dimensions.Z)
		end)
	end
end
