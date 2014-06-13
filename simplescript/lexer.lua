local function require(file)
	return dofile(shell.resolve(file))
end

local function startsWith(str, start)
	return str:sub(1, #start) == start
end

local function trim(str)
	return str:gsub("^%s+", "")
end

local Lexer = {}
Lexer.__index = Lexer

function Lexer.new()
	local self = setmetatable({}, Lexer)
	self.parseTree = {}
	return self
end

function Lexer:parseFunctionCall(funcCall)
	local pkg, callInfo = funcCall:match("(%w+):(.+)")
	callInfo = trim(callInfo)
	
	local tbl = { ["type"] = "call", ["pkg"] = pkg, funcs = {} }
	
	local function parseCallInfo(info)
		info = info:gsub("%s+", "")
		local funcTable = {}
		
		for call in info:gmatch("[^,]+") do
			local paramsTable = {}
			local name,params,repetition = call:match("(%w+)%s-%[(.-)]%s-%*?%s-(%d*)")
			assert(name, "nameless function")
			
			params = params:gsub("%s+", "")
			
			for param in params:gmatch("[^,]+") do
				table.insert(paramsTable, param)
			end
			
			table.insert(funcTable, {
				["name"] = name,
				["params"] = paramsTable,
				["repetition"] = tonumber(repetition)
			})
		end
		
		return funcTable
	end
	
	tbl["funcs"] = parseCallInfo(callInfo)
	return tbl
end

function Lexer:getFunctionCall(line)
	local call = line:match("%w+:.+")
	return call
end

function Lexer:getStatement(line)
	local statement = line:match("%w+%s-{%s-.-%s-}:")
	return statement
end

function Lexer:parseStatement(line)
	local type, condition = line:match("(%w+)%s-{%s-(.-)%s-}:")
	condition = condition:gsub("%s+", "")
	
	local tbl = { ["type"] = "statement", ["kind"] = type, ["condition"] = condition }
	return tbl
end

function Lexer:tokenise(str)
	-- Please do prepare for incredible hardcoding.
	-- But it's a jam, so it's alright ;).
	
	local lineCount = 0
	
	for line in str:gmatch("[^\n;]+") do
		lineCount = lineCount + 1
		
		local okay, err = pcall(function()
			if not startsWith(line, "//") and not startsWith(line, "#") and not startsWith(line, "--") then		
				local statement = self:getStatement(line)
				if statement ~= nil then
					table.insert(self.parseTree, self:parseStatement(line))
					return
				end
				
				local call = self:getFunctionCall(line)
				if call ~= nil then
					table.insert(self.parseTree, self:parseFunctionCall(call))
				end
			end
		end)
		
		if not okay then
			return lineCount .. ": " .. err
		end
	end
end

return Lexer