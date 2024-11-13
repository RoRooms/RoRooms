local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script.Server)
else
	return require(script.Client)
end

--[=[
	@class Rorooms
]=]

--[=[
	@method Start
	@within Rorooms

	Starts Rorooms.
]=]

--[=[
	@method Configure
	@within Rorooms

	@param Config Config

	Reconciles Rorooms' config to your liking.

	[`Config` type available here](https://github.com/Rorooms/Rorooms/blob/main/src/API/Config.luau)
]=]

--[=[
	@method Prompt
	@within Rorooms
	@client

	@param Prompt Prompt

	Prompts the client, with support for callback buttons.

	[`Prompt` type available here](https://github.com/Rorooms/Rorooms/blob/main/src/Client/UI/States/Prompts.luau)
]=]
