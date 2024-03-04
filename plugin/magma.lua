function MagmaVisualSendLines(mode)
    local bufnr = vim.api.nvim_get_current_buf()

    local start_pos = vim.api.nvim_buf_get_mark(bufnr, mode == 'visual' and "<" or '[')
    local end_pos = vim.api.nvim_buf_get_mark(bufnr, mode == 'visual' and ">" or ']')

    vim.api.nvim_command('MagmaVisualSend '.. start_pos[1] .. ',' .. end_pos[1])
end

function EvaluateCodeBlock(skipToNextCodeBlock)
    local original_cursor = vim.api.nvim_win_get_cursor(0)
    local mode = vim.api.nvim_get_mode().mode
    if mode == 'i' or mode == 'v' or mode == 'V' or mode == '' then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
    end
    local current_line = vim.api.nvim_get_current_line()
    if current_line == "# +" or current_line == "# -" then
        vim.cmd('normal! j')
    end
    local pattern = '# [-+]$'
    local start_row = vim.fn.search(pattern, 'bnW') + 1
    local end_row = vim.fn.search(pattern, 'nW') - 1
    if end_row == -1 then end_row = vim.fn.line('$') end
    if start_row > end_row then return end

    vim.api.nvim_command('MagmaVisualSend '.. start_row .. ',' .. end_row)

    if skipToNextCodeBlock and end_row == vim.fn.line('$') then
        vim.api.nvim_buf_set_lines(0, -1, -1, false, {"# +"})
        vim.api.nvim_buf_set_lines(0, -1, -1, false, {""})
    elseif end_row == vim.fn.line('$') - 1 then
        vim.api.nvim_buf_set_lines(0, -1, -1, false, {""})
    end
    if skipToNextCodeBlock then
        vim.api.nvim_win_set_cursor(0, {end_row + 2, 0})
    end
end
