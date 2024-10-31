local ContentProvider = game:GetService("ContentProvider")

local RoRooms = script.Parent.Parent.Parent.Parent
local Assets = require(RoRooms.SourceCode.Shared.Assets)

export type ContentIds = { string }
export type ContentIdTree = string | { [string]: ContentIdTree }

local PreloadingController = {
	Name = script.Name,
}

function PreloadingController:PreloadTree(Tree: ContentIdTree)
	ContentProvider:PreloadAsync(self:CompileContentTree(Tree))
end

function PreloadingController:CompileContentTree(Tree: ContentIdTree)
	local ContentIds: ContentIds = {}

	for _, Entry in pairs(Tree) do
		if typeof(Entry) == "table" then
			for _, SubEntry in ipairs(self:CompileContentTree(Entry)) do
				table.insert(ContentIds, SubEntry)
			end
		elseif typeof(Entry) == "string" then
			table.insert(ContentIds, Entry)
		end
	end

	return ContentIds
end

function PreloadingController:KnitStart()
	self:PreloadTree(Assets.Icons)
end

function PreloadingController:KnitInit() end

return PreloadingController
