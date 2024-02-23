local M = {}

local function project(row, col)
	return row * 100000 + col
end

function M.project_start(node)
	local row, col = node:range()
	return project(row, col)
end

function M.project_end(node)
	local _, _, row, col = node:range()
	return project(row, col)
end

function M.contains(a, b)
	if M.project_start(a) > M.project_start(b) then
		return false
	end

	if M.project_end(a) < M.project_end(b) then
		return false
	end

	return true
end

function M.get_bufnr(bufnr)
	return bufnr or vim.api.nvim_get_current_buf()
end

function M.valid_buffer()
	local ft = vim.bo[M.get_bufnr()].ft
	return ft == "json" or ft == "yaml"
end

function M.getpos()
	return vim.fn.line(".") - 1, vim.fn.col(".") - 1
end

function M.move(node)
	local new_row, new_col = node:range()
	vim.api.nvim_win_set_cursor(0, { new_row + 1, new_col })
end

return M
