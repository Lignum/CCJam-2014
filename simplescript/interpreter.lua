local Interpreter = {}
Interpreter.__index = Interpreter

function Interpreter.new()
	local self = setmetatable({}, Interpreter)
	
	return self
end

function Interpreter:callFunction(func)

end

function Interpreter:interpret(parseTree)
	for _,v in ipairs(parseTree) do
		if v.type == "call" then
			for _,j in ipairs(parseTree) do
				self:callFunction(j)
			end
		elseif v.type == "statement" then
		
		end
	end
end