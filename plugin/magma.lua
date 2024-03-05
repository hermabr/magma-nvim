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
    local inserted_extra_new_line = false
    if end_row == -1 then end_row = vim.fn.line('$') end
    if start_row > end_row then return end

    if end_row == vim.fn.line('$') then
        if vim.api.nvim_buf_get_lines(0, vim.fn.line('$') - 1, vim.fn.line('$'), false)[1] ~= "" then
            vim.api.nvim_buf_set_lines(0, -1, -1, false, {""})
            inserted_extra_new_line = true
        else
            end_row = end_row - 1
        end
    end

    if skipToNextCodeBlock and (end_row == vim.fn.line('$') or inserted_extra_new_line) then
        vim.api.nvim_buf_set_lines(0, -1, -1, false, {"# +"})
        vim.api.nvim_buf_set_lines(0, -1, -1, false, {""})
    end
    vim.api.nvim_command('MagmaVisualSend '.. start_row .. ',' .. end_row)

    if skipToNextCodeBlock then
        if inserted_extra_new_line then
            vim.api.nvim_win_set_cursor(0, {end_row + 3, 0})
        else
            vim.api.nvim_win_set_cursor(0, {end_row + 2, 0})
        end
    end
end

function JumpUpSection()
    local cur_row, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local pattern = '# [-+]$'
    local found_row = vim.fn.search(pattern, 'bnW')
    if found_row == 0 then
        return
    end
    if cur_row == found_row then
        vim.cmd('normal! k')
        local new_row = vim.fn.search(pattern, 'bnW')
        vim.api.nvim_win_set_cursor(0, {found_row, 0})
    else
        vim.api.nvim_win_set_cursor(0, {found_row, 0})
    end
    vim.cmd('normal! zz')
    vim.cmd('nohlsearch')
end

vim.api.nvim_set_keymap('n', 's', "<cmd>set opfunc=v:lua.MagmaVisualSendLines<CR>g@", {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', 'ss', "<cmd>MagmaEvaluateLine<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', 's', ":<C-u>lua MagmaVisualSendLines('visual')<CR>", {silent = true, noremap = true})

vim.api.nvim_set_keymap('n', 'S', "<cmd>MagmaInit python3<CR>", {noremap = true, silent = true})

vim.keymap.set({'i', 'n', 'v'}, '<C-Enter>', function() EvaluateCodeBlock(false) end, {noremap = true, silent = true})
vim.keymap.set({'i', 'n', 'v'}, '<S-Enter>', function() EvaluateCodeBlock(true) end, {noremap = true, silent = true})

vim.api.nvim_set_keymap('n', '[n', ':lua JumpUpSection()<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', ']n', '/# [-+]$<CR><CMD>noh<CR>zz', {noremap = true, silent = true})
