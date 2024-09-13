local Signal = require(script.Parent.Parent.Parent.Parent.Parent.Signal)

export type AttributeBind = {
	Instance: Instance,
	Attribute: string,
	Value: any,
	Fallback: any?,
	_Connections: { RBXScriptConnection | Signal.Connection },

	Changed: Signal.Signal<any>,

	_Update: (self: AttributeBind) -> any,
	Get: (self: AttributeBind) -> any,
	Bind: (Instance: Instance, Attribute: string, Fallback: any?) -> (),
	Observe: (self: AttributeBind, Callback: (Value: any) -> ()) -> (),
}

local AttributeBind = {}

function AttributeBind.Observe(self: AttributeBind, Callback: (Value: any) -> ())
	assert(typeof(Callback) == "function", `Callback is not a function.`)

	Callback(self.Value)
	table.insert(
		self._Connections,
		self.Changed:Connect(function()
			Callback(self.Value)
		end)
	)
end

function AttributeBind.Get(self: AttributeBind): any
	return self.Value
end

function AttributeBind._Update(self: AttributeBind)
	local OldValue = self.Value
	local Value = self.Instance:GetAttribute(self.Attribute)

	if Value == nil then
		Value = self.Fallback
	end

	self.Value = Value

	if Value ~= OldValue then
		self.Changed:Fire(Value)
	end

	return Value
end

function AttributeBind.Destroy(self: AttributeBind)
	for _, Connection in ipairs(self._Connections) do
		Connection:Disconnect()
	end
end

function AttributeBind.Bind(Instance: Instance, Attribute: string, Fallback: any?): AttributeBind
	assert(typeof(Instance) == "Instance", `{tostring(Instance)} is not an Instance.`)
	assert(typeof(Attribute) == "string", `{tostring(Attribute)} is not a string.`)

	local self = table.clone(AttributeBind)
	self._Connections = {}
	self.Instance = Instance
	self.Attribute = Attribute
	self.Fallback = Fallback
	self.Changed = Signal.new()

	self:_Update()
	table.insert(
		self._Connections,
		Instance:GetAttributeChangedSignal(Attribute):Connect(function()
			self:_Update()
		end)
	)

	self.Instance.Destroying:Connect(function()
		self:Destroy()
	end)

	return self
end

return AttributeBind
