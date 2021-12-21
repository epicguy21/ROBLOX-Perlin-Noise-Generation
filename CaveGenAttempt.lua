local Block = require(game:GetService("ServerStorage").Block)
local Seed = 2
local Resolution = 4
local NumWorm = 1
local WormScale = 500
local Dimensions = {
	X = 512,
	Y = 256,
	Z = 512
}

local WormsTable = {}

for WormsToSpawn = 20, 0, -1 do
	NumWorm = NumWorm+1
	local sX = math.noise(NumWorm/Resolution+.1,Seed)
	local sY = math.noise(NumWorm/Resolution+sX+.1,Seed)
	local sZ = math.noise(NumWorm/Resolution+sY+.1,Seed)
	local WormCF = CFrame.new(sX*WormScale,sY*WormScale,sZ*WormScale)
	local Dist = (math.noise(NumWorm/Resolution+WormCF.p.magnitude,Seed)+.5)*WormScale
	WormCF = WormCF + Vector3.new(Dimensions.X/2, Dimensions.Y/2, Dimensions.Z/2)
	print("Worm "..NumWorm.." spawning at "..WormCF.X..", "..WormCF.Y..", "..WormCF.Z)
	for i = 1,Dist do
		wait()
		local X,Y,Z = math.noise(WormCF.X/Resolution+.1,Seed),math.noise(WormCF.Y/Resolution+.1,Seed),math.noise(WormCF.Z/Resolution+.1,Seed)
		WormCF = WormCF*CFrame.Angles(X*2,Y*2,Z*2)*CFrame.new(0,0,-Resolution)
		table.insert(WormsTable, WormCF)
		Block.new(1, WormCF.p.X, WormCF.p.Y, WormCF.p.Z, "Grass"):show()
	end
end
