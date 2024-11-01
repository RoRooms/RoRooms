local ConfigUtils = {}

function ConfigUtils:IfString(Value: any): string?
	if typeof(Value) == "string" then
		return Value
	else
		return nil
	end
end

function ConfigUtils:IfNumber(Value: any): number?
	if typeof(Value) == "number" then
		return Value
	else
		return nil
	end
end

function ConfigUtils:GetColor(Instance: Instance)
	local LevelRequirement = Instance:GetAttribute("LevelRequirement")
	return (LevelRequirement and Color3.fromRGB(68, 55, 68))
end

function ConfigUtils:GetCategory(Instance: Instance): string?
	local LevelRequirement = Instance:GetAttribute("LevelRequirement")
	local Category = self:IfString(Instance:GetAttribute("Category"))

	if Category then
		return Category
	elseif LevelRequirement then
		return "Unlockable"
	else
		return nil
	end
end

function ConfigUtils:AnimationToEmote(Animation: Animation)
	return {
		DisplayName = Animation.Name,
		Animation = Animation,
		Emoji = self:IfString(Animation:GetAttribute("Emoji")),
		LevelRequirement = self:IfNumber(Animation:GetAttribute("LevelRequirement")),
		LabelIcon = self:IfString(Animation:GetAttribute("LabelIcon")),
		LabelText = self:IfString(Animation:GetAttribute("LabelText")),
		Color = self:GetColor(Animation),
		Category = self:GetCategory(Animation),
	}
end

function ConfigUtils:ToolToItem(Tool: Tool)
	return {
		DisplayName = Tool.Name,
		Tool = Tool,
		LevelRequirement = Tool:GetAttribute("LevelRequirement"),
		LabelIcon = Tool:GetAttribute("LabelIcon"),
		LabelText = Tool:GetAttribute("LabelText"),
		Color = self:GetColor(Tool),
		Category = self:GetCategory(Tool),
	}
end

function ConfigUtils:CompileEmotes(EmotesFolder: Folder)
	local Emotes = {}

	for _, EmoteAnimation in ipairs(EmotesFolder:GetChildren()) do
		local EmoteId = EmoteAnimation:GetAttribute("EmoteId")
		if EmoteId then
			Emotes[EmoteId] = self:AnimationToEmote(EmoteAnimation)
		end
	end

	return Emotes
end

function ConfigUtils:CompileItems(EmotesFolder: Folder)
	local Items = {}

	for _, ItemTool in ipairs(EmotesFolder:GetChildren()) do
		local ItemId = ItemTool:GetAttribute("ItemId")
		if ItemId then
			Items[ItemId] = self:ToolToItem(ItemTool)
		end
	end

	return Items
end

function ConfigUtils:EnsureSoundGroup(SoundGroup: Instance?): SoundGroup
	if SoundGroup == nil then
		return Instance.new("SoundGroup")
	end
	if not SoundGroup:IsA("SoundGroup") then
		return Instance.new("SoundGroup")
	end

	return SoundGroup
end

function ConfigUtils:EnsureFolder(Name: string, Parent: Instance): Folder
	local Folder = Parent:FindFirstChild(Name)

	if Folder == nil then
		Folder = Instance.new("Folder")
	end

	return Folder
end

function ConfigUtils:GetAvatarEditorCallback(Parent: Instance): (() -> ())?
	local CallbackModule = Parent:FindFirstChild("AvatarEditorCallback")
	if CallbackModule and CallbackModule:IsA("ModuleScript") then
		return require(CallbackModule)
	else
		return nil
	end
end

return ConfigUtils
