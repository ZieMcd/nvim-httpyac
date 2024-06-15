local M = {}

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
	if HttpyacEnvs then
		table.insert(cmd, "-e")
		for _, e in pairs(HttpyacEnvs) do
			table.insert(cmd, e)
		end
	end

	if not Buf then
		api.nvim_command(":vnew<CR>")
		api.nvim_command(":setlocal buftype=nofile")
		api.nvim_command(":setlocal bufhidden=hide")
		api.nvim_command(":setlocal noswapfile")
		api.nvim_command(":set filetype=http")
		Buf = vim.api.nvim_get_current_buf()
	end

	local obj = vim.system(cmd, {
		text = true,
	}):wait()

	local line = 0

	for s in obj.stdout:gmatch("[^\r\n]+") do
		api.nvim_buf_set_lines(Buf, line, -1, false, { s })
		line = line + 1
	end
	for s in obj.stderr:gmatch("[^\r\n]+") do
		api.nvim_buf_set_lines(Buf, line, -1, false, { s })
		line = line + 1
	end
end

M.addEnv = function(e)
	if HttpyacEnvs then
		table.insert(HttpyacEnvs, e)
	else
		HttpyacEnvs = { e }
	end
end

M.removeEnv = function(env)
	if HttpyacEnvs then
		for i, e in pairs(HttpyacEnvs) do
			if e == env then
				table.remove(HttpyacEnvs, i)
			end
		end
	end
end

return M
