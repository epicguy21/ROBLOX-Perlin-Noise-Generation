local francis = game:GetService("ServerStorage"):WaitForChild("francis")
local replicatedfrancis = game:GetService("ReplicatedStorage"):WaitForChild("francis")
local Remote = replicatedfrancis:WaitForChild("RemoteEvent")
local Block = require(francis:WaitForChild("Block"))

local Blocks = {
	Dirt = Block.new(1),
	Grass = Block.new(1),
	Sand = Block.new(1),
	Snow = Block.new(1),
	Water = Block.new(1)
}

local Updates = {}
local requiresUpdate = true
local World = {}
function World:Set(Position, BlockName)
	self[tostring(Position)] = BlockName
end

local Seed = math.random(1,9999999)
local Amplitude = 25
local Scale = 100
local Dimensions = {
	X = 128,
	Y = 128,
	Z = 128
}
local Size = 4

local function GenChunk(StartX, StartY, StartZ, WithCaves)
	for X =  StartX, StartX + Dimensions.X, 4 do
		local ScaledX = X/Scale
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
					Updates[Vector3.new(X, Y, Z)] = BlockName
					if CreateSnow then
						Updates[Vector3.new(X, Y + 2.5, Z)] = "Snow"
					end
					requiresUpdate = true
				end
			end
		end
	end
end

spawn(function()
	while wait(0.05) do
		if requiresUpdate then
			for position, blockName in next, Updates do
				World:Set(position, blockName ~= "null" and blockName or nil)
			end
			Remote:FireAllClients("updateWorld", Updates)
			Updates = {}
			requiresUpdate = false
		end
	end
end)

local PlayerData = {}

Remote.OnServerEvent:Connect(function(Player, Action, ...)
	local playerData = PlayerData[Player]
	if not playerData then
		playerData = {
			Inventory = {} --// stackName ; Qty
		}
		PlayerData[Player] = playerData
	end
	if Action == "Destroy" then
		local Position = ...
		local stackName = World[tostring(Position)]
		Updates[Position] = "null"
		Updates[Position + Vector3.new(0, 2.5, 0)] = "null"
		local newQty = (playerData.Inventory[stackName] or 0) + 1
		playerData.Inventory[stackName] = newQty
		Remote:FireClient(Player, "updateInventory", stackName, newQty)
		requiresUpdate = true
	end
end)

for X = 0, 2, 1 do
	for Y = 0, 2, 1 do
		coroutine.wrap(GenChunk)(X*Dimensions.X, 0, Y*Dimensions.Z)
	end
end
