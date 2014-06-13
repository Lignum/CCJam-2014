local Interpreter = {}
Interpreter.__index = Interpreter

function Interpreter.new()
	local self = setmetatable({}, Interpreter)
	self.environment = {}
	return self
end

function Interpreter:loadPackage(file)
	table.insert(self.environment, {
		name = fs.getName(file),
		functions = dofile(file)
	})
end

function Interpreter:getPackageFunction(pkg, func)
	for _,v in ipairs(self.environment) do
		if v.name == pkg then
			for k,j in pairs(v.functions) do
				if k == func then
					return j
				end
			end
		end
	end
	
	return nil
end

local function parseParams(params)
	local tbl = {}
	
	for _,v in ipairs(params) do
		local str = v:match("^\"(.-)\"")
		if str ~= nil then
			table.insert(tbl, str)
		else
			if tonumber(v) ~= nil then
				table.insert(tbl, tonumber(v))
			else
				if v == "true" then
					table.insert(tbl, true)
				elseif v == "false" then
					table.insert(tbl, false)
				else
					error("invalid parameter!")
				end
			end
		end
	end
	
	return tbl
end

function Interpreter:callFunction(pkg, func, params)
	local name = func.name
	local funct = self:getPackageFunction(pkg, name)
	if funct == nil then
		error("package '" .. tostring(pkg) .. "' has no function named '" .. tostring(name) .. "'")
	end
	return funct(unpack(parseParams(params)))
end

local statements = {
	["conditional"] = { "perchance", "if" },
	["conditional_contradictory"] = { "otherwise", "else" },
	["conditional_conditional_contradictory"] = { "perhaps", "maybe" },
	["loop"] = { "repeat", "do" }
}

function Interpreter:getStatementType(statement)
	for k,v in pairs(statements) do
		if v[statement] ~= nil then
			return k
		end
	end
	return nil
end

function Interpreter:interpret(parseTree)
	for _,v in ipairs(parseTree) do
		if v.type == "call" then
			for _,j in ipairs(v.funcs) do
				for i=1,j.repetition or 1 do
					self:callFunction(v.pkg, j, j.params)
				end
			end
		elseif v.type == "statement" then
			--[[if self:getStatementType(v.kind) == "conditional" then
				
			end]]
		end
	end
end

return Interpreter