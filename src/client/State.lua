local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

local State = {
	snapshot = nil,
	Changed = Signal.new(),
}

function State.set(snapshot)
	State.snapshot = snapshot
	State.Changed:Fire(snapshot)
end

function State.data()
	return State.snapshot and State.snapshot.data
end

function State.computed()
	return State.snapshot and State.snapshot.computed
end

return State
