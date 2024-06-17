local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local nvim_httpyac = require("nvim-httpyac")
local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
	return
end

local function addEnv(opts)
	pickers
		.new(opts, {
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					nvim_httpyac.addEnv(selection.value)
				end)
				return true
			end,
			prompt_title = "add .env files",
			finder = finders.new_table({
				results = GetEnvsFiles(),
				entry_maker = function(entry)
					return {
						value = entry,
						display = function()
							return entry
						end,
						ordinal = entry,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
		})
		:find()
end

local function removeEnv(opts)
	pickers
		.new(opts, {
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					nvim_httpyac.removeEnv(selection.value)
				end)
				return true
			end,
			prompt_title = "remove .env files",
			finder = finders.new_table({
				results = nvim_httpyac.httpyacEnvs,
				entry_maker = function(entry)
					return {
						value = entry,
						display = function()
							return entry
						end,
						ordinal = entry,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
		})
		:find()
end

function GetEnvsFiles()
	local obj = vim.system({
		"fd",
		"'.env$'",
		"-d",
		"1",
		"&&",
		"fd",
		"'.env$'",
		"--search-path",
		"env",
		"&&",
		"fd",
		"'.env$'",
		"--search-path",
		"HubSpot",
	}, { text = true }):wait()
	return vim.split(obj.stdout, "\n")
end

return telescope.register_extension({
	exports = {
		add_env = addEnv,
		remove_env = removeEnv,
	},
})
