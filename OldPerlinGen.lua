local Block = require(game:GetService("ServerStorage").Block)
local Seed = 2
local Amplitude = 300
local Scale = 300
local Dimensions = {
	X = 128,
	Y = 256,
	Z = 128
}

local Size = 4
local function GenChunk(StartX, StartY, StartZ, WithCaves)
	coroutine.wrap(function()
		for X =  StartX, StartX + Dimensions.X, 4 do
			local ScaledX = X/Scale
			wait()
			coroutine.wrap(function()
				for Z = StartZ, StartZ + Dimensions.Z, 4 do
					local ScaledZ = Z/Scale
					for Y = StartY, StartY + Dimensions.Y, 4 do
						local BlockName;
						local ScaledY = Y/Scale
						local Height = math.floor(math.clamp(math.noise(ScaledX, ScaledZ, Seed),0,1) * Amplitude) + Dimensions.Y/2
						local XNoise = math.floor(math.clamp(math.noise(ScaledY, ScaledZ, Seed),0,1) * Amplitude)
						local ZNoise = math.floor(math.clamp(math.noise(ScaledX, ScaledZ, Seed),0,1) * Amplitude)
						local Density = XNoise + ZNoise + Height
						local CreateSnow = Density > 260
						coroutine.wrap(function()
							if Y - 1 == Height or Y - 2 == Height or Y - 3 == Height or Y == Height then
								if Height == 0 then
									BlockName = "Water"
								else
									if Density > -10 and Density < 15 then
										BlockName = "Sand"
									elseif CreateSnow then
										BlockName = "Dirt"
									else
										BlockName = "Grass"
									end
								end
							elseif Y <= Height then
								BlockName = "Dirt"
							end
							if BlockName then
								local NewBlock = Block.new(1, X, Y, Z, BlockName)
								if CreateSnow then
									Block.new(1, X, Y + 2.5, Z, "Snow"):show()
								end
								NewBlock:show()
							end
						end)()
					end
				end
			end)()
		end
	end)()
end

for X = 0, 2, 1 do
	for Y = 0, 2, 1 do
		coroutine.wrap(GenChunk)(X*Dimensions.X, 0, Y*Dimensions.Z)
	end
end
