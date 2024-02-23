local parsers = require("nvim-treesitter.parsers")
local utils = require("yvim.utils")

local M = {}

local function i(value)
	print(vim.inspect(value))
end

-- TODO: create one for yaml or make it compatible with both
local function get_root(bufnr)
	-- local ft = vim.bo[bufnr].ft
	local ft = vim.bo[utils.get_bufnr()].ft
	local parser = parsers.get_parser(bufnr, ft)
	if not parser then
		error("No treesitter parser found. Install one using :TSInstall <language>")
	end
	return parser:parse()[1]:root()
end

-- local function get_root_yaml(bufnr)
-- 	local parser = parsers.get_parser(bufnr, "yaml")
-- 	if not parser then
-- 		error("No treesitter parser found. Install one using :TSInstall <language>")
-- 	end
-- 	return parser:parse()[1]:root()
-- end

-- TODO: make sure this works for yaml, otherwise create a new one
local function get_parent(bufnr, count)
	local ft = vim.bo[utils.get_bufnr()].ft
	if not count or count < 1 then
		count = 1
	end

	local row, col = utils.getpos()
	local root = get_root(bufnr)
	local current_node = root:named_descendant_for_range(row, col, row, col)
	if not current_node then
		return
	end

	local current_count = 0
	while current_node:parent() ~= nil and current_node:parent():type() ~= "document" do
		current_node = current_node:parent()

		local type_comp = "pair"
		if ft == "yaml" then
			type_comp = "block_mapping_pair"
		end

		if current_node:type() == type_comp then
			current_count = current_count + 1
			if current_count == count then
				break
			end
		end
	end

	return current_node
end

-- TODO: create one for yaml
local function get_first_child(bufnr)
	local current_node = get_parent(bufnr, 1)
	local ft = vim.bo[utils.get_bufnr()].ft
	local query = {}

	if ft == "yaml" then
		query = vim.treesitter.query.parse("yaml", "(block_mapping_pair) @block_mapping_pair")
	elseif ft == "json" then
		query = vim.treesitter.query.parse("json", "(pair) @pair")
	end

	local lowest = nil
	local lowest_diff = nil
	for _, node, _ in query:iter_captures(current_node, bufnr, 0, -1) do
		if current_node:id() ~= node:id() and (lowest == nil or utils.contains(current_node, lowest)) then
			if lowest == nil then
				lowest = node
				lowest_diff = math.abs(utils.project_start(current_node) - utils.project_start(lowest))
			else
				local diff = math.abs(utils.project_start(current_node) - utils.project_start(lowest))
				if diff < lowest_diff then
					lowest = node
					lowest_diff = diff
				end
			end
		end
	end

	return lowest
end

-- ==============================

function M.to_immediate()
	if not utils.valid_buffer() then
		return
	end
	utils.move(get_parent(utils.get_bufnr(), 1))
end

function M.to_parent()
	if not utils.valid_buffer() then
		return
	end
	utils.move(get_parent(utils.get_bufnr(), 2))
end

function M.next_sibling()
	if not utils.valid_buffer() then
		return
	end
	local pair = get_parent(utils.get_bufnr(), 1)
	local next = pair:next_named_sibling()

	if next then
		utils.move(next)
	else
		utils.move(pair)
	end
end

function M.prev_sibling()
	if not utils.valid_buffer() then
		return
	end
	local pair = get_parent(utils.get_bufnr(), 1)
	local prev = pair:prev_named_sibling()

	if prev then
		utils.move(prev)
	else
		utils.move(pair)
	end
end

function M.descend()
	if not utils.valid_buffer() then
		return
	end
	local first_child = get_first_child()
	if first_child then
		utils.move(first_child)
	end
end

return M
