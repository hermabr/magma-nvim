function MagmaVisualSendLines(mode)
    local bufnr = vim.api.nvim_get_current_buf()

    local start_pos = vim.api.nvim_buf_get_mark(bufnr, mode == 'visual' and "<" or '[')
    local end_pos = vim.api.nvim_buf_get_mark(bufnr, mode == 'visual' and ">" or ']')

    vim.api.nvim_command('MagmaVisualSend '.. start_pos[1] .. ',' .. end_pos[1])
end
