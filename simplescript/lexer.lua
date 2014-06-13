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
	
	local tbl = { ["pkg"] = pkg, funcs = {} }
	
	local function parseCallInfo(info)
		info = info:gsub("%s-", "")
		local funcTable = {}
		
		for call in info:gmatch("[^,]+") do
			local paramsTable = {}
			local name,params,repetition = call:match("(%w+)%[?(.-)]?%*?(%d-)")
			assert(name, "nameless function")
			
			params = params:gsub("%s-", "")
			
			for param in params:gmatch("[^,]+") do
				table.insert(paramsTable, param)
			end
			
			funcTable["name"] = name
			funcTable["params"] = paramsTable
			funcTable["repetition"] = tonumber(repetition)
		end
		
		return funcTable
	end
	
	tbl["funcs"] = parseCallInfo(callInfo)
	return tbl
end

function Lexer:findFunctionCalls(line)
	local tbl = {}
	
	for call in line:gmatch("(%w+):(.+)") do
		local c = call:gsub("%s-", "")
		table.insert(tbl, c)
	end
	
	if #tbl == 0 then return nil end
	return tbl
end

function Lexer:tokenise(str)
	-- Please do prepare for incredible hardcoding.
	-- But it's a jam, so it's alright ;).
	
	local lineCount = 0
	
	for line in str:gmatch("[^\n;]+") do
		lineCount = lineCount + 1
		
		local okay, err = pcall(function()
			if not (startsWith(line, "//") or startsWith(line, "#") or startsWith(line, "--")) then		
				if self:findFunctionCalls(line) ~= nil then
					local func = self:parseFunctionCall(line)
				end
			end
		end)
		
		if not okay then
			return lineCount .. ":" .. err
		end
	end
end

return Lexer