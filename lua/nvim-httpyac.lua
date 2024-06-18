local M = {}
local httpyacEnvs = {}
local buf = -1

M.setup = function()
	vim.api.nvim_create_user_command("HttpyacSend", function()
		M.send()
	end, {})
	vim.api.nvim_create_user_command("HttpyacEnvAdd", function(opts)
		M.addEnv(opts.fargs[1])
	end, { nargs = "+" })
	vim.api.nvim_create_user_command("HttpyacEnvRemove", function(opts)
		M.removeEnv(opts.fargs[1])
	end, { nargs = "+" })
end

M.send = function()
	local api = vim.api
	local file = vim.fn.expand("%")
	local lineNum = "-l " .. vim.fn.line(".")
	local cmd = { "httpyac", "send", file, lineNum }

	if next(httpyacEnvs) ~= nil then
		table.insert(cmd, "-e")
		for _, e in pairs(httpyacEnvs) do
			table.insert(cmd, e)
		end
	end

	if not vim.api.nvim_buf_is_loaded(buf) then
		api.nvim_command(":vnew<CR>")
		api.nvim_command(":setlocal buftype=nofile")
		api.nvim_command(":setlocal bufhidden=hide")
		api.nvim_command(":setlocal noswapfile")
		api.nvim_command(":set filetype=http")
		buf = vim.api.nvim_get_current_buf()
	end

	if vim.fn.bufwinnr(buf) == -1 then
		vim.api.nvim_command("vs" .. buf)
		vim.api.nvim_command("buffer " .. buf)
	end

	local obj = vim.system(cmd, {
		text = true,
	}):wait()

	local line = 0

	for s in obj.stdout:gmatch("[^\r\n]+") do
		api.nvim_buf_set_lines(buf, line, -1, false, { s })
		line = line + 1
	end
	for s in obj.stderr:gmatch("[^\r\n]+") do
		api.nvim_buf_set_lines(buf, line, -1, false, { s })
		line = line + 1
	end
end

M.addEnv = function(env)
	for _, e in pairs(httpyacEnvs) do
		if e == env then
			vim.api.nvim_err_writeln("env" .. env .. "already added")
			return
		end
	end
	table.insert(httpyacEnvs, env)
end

M.removeEnv = function(env)
	for i, e in pairs(httpyacEnvs) do
		if e == env then
			table.remove(httpyacEnvs, i)
			return
		end
	end
	vim.api.nvim_err_writeln("env" .. env .. "not found")
end

M.httpyacEnvs = httpyacEnvs

return M
