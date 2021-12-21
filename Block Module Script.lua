 local Block = {}
Block.__index = {
	Break = function(self, IsInstant)
		if self.Block then
			self.Hardness = self.Hardness - 1
			if IsInstant or self.Hardness <= 0 then
				self.Block:Destroy()
			end
		end
	end,
	show = function(self)
		local Block = script:FindFirstChild(self.Name)
		if Block then
			Block = Block:Clone()
			self.Block = Block
			Block.Position = self.Position
			Block.Parent = workspace.Blocks
		end
	end
}

function Block.new(Hardness, X, Y, Z, Name)
	local newBlock = {
		Name = Name,
		Block = nil,
		Position = Vector3.new(X, Y, Z),
		Hardness = Hardness
	}
	return setmetatable(newBlock, Block)
end
 
return Block
