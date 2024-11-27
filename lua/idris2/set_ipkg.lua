local M = {}

-- Send "setIpkg" command to LSP
function M.send(ipkg)
	vim.lsp.buf_request(0, 'workspace/executeCommand', {command = "setIpkg", arguments = {ipkg}}, function() end)
end

return M
