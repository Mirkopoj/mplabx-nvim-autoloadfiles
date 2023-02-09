local function file_exists(name)
   local f = io.open(name, "r")
   return f ~= nil and io.close(f)
end

local function table_contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

local function create_folder(dir, table)
	if table_contains(table, dir) then
		return
	end

	local logicalFolder = {
		_attr = {
			name = dir,
			displayName = dir,
			projectFiles = "true"
		}
	}
	table.insert(
		table,
		logicalFolder
	)
end

local function add_folder(dir, table)
	if dir == '.' then
		return table
	end

	local folders = {}
	for w in (dir .. "/"):gmatch("([^/]*)/") do
		table.insert(folders, w)
	end

	for _, v in ipairs(folders) do
		create_folder(v, table)
		table = table.v
	end

	return table

end

function Add_file_to_mplab_project()

	print("Entró al funcion")

	if not file_exists("nbproject/configurations.xml") then
		return
	end

	local file_extention = vim.fn.expand('%:e')
	local logicalFolderName
	if file_extention == 'c' then
		logicalFolderName = "SourceFiles"
	elseif file_extention == 'h' then
		logicalFolderName = "HeaderFiles"
	else
		return
	end


	local xml2lua = require("xml2lua")

	--Uses a handler that converts the XML to a Lua table
	local handler = require("xmlhandler.tree")

	local handler_conf = handler:new()
	local parser_pub = xml2lua.parser(handler_conf)
	parser_pub:parse(xml2lua.loadFile("nbproject/configurations.xml"))

	local logicalFolders = handler_conf.root.ConfigurationDescriptor.logicalFolder
	local file_dir = vim.fn.expand('%:p:~:.:h')
	local itemPathName = vim.fn.expand('%:t')

	for k, v in ipairs(logicalFolders) do
		if v._attr.name == logicalFolderName then
			local table_to_insert = add_folder(file_dir, logicalFolders[k])
			table.insert(
				table_to_insert,
				{itemPath = itemPathName}
			)
			break
		end
	end

	print(xml2lua.toXml(handler_conf.root, "ConfigurationDescriptor"))
	--local f = io.open("nbproject/configurations.xml")
	--io.write(f, xml2lua.toXml(handler_conf.root))
	--io.close(f)

end

vim.api.nvim_create_autocmd("BufferNew", {callback = Add_file_to_mplab_project()})
