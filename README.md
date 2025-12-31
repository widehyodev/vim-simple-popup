# vim-simple-popup

A lightweight Vim plugin that leverages the native popup window API (introduced in Vim 8.2) to display Ex commands, system commands, jump lists, and buffer menus in a floating window.

## Requirements

* **Vim 8.2** or higher (required for popup window support).

## Features (Commands)

* **PopupEx {command}**: Executes an Ex command (e.g., `:messages`, `:map`) and displays the output in a popup window.
* **PopupExTail {command}**: Same as `:PopupEx`, but automatically scrolls to the bottom of the output (ideal for logs or messages).
* **PopupSystem {shellcommand}**: Runs a system shell command and shows the results in a popup.
* **PopupJumps**/**PopupChanges**: Opens the jumplist or changelist in a popup for interactive navigation.
* **BufferMenu [filter]**: Displays a list of listed buffers. Optionally filters the list by the provided search string.
* **SearchAcrossFiles {pattern}**: Searches for the given pattern across files within the current working directory (`:pwd`) using `grep -Irn` and opens the selected result.

---

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'widehyodev/vim-simple-popup'
```

---

## Configuration & Usage
The following examples demonstrate how to configure the tabline and set up keybindings for various features. You can add these to your init.vim or .vimrc.

### Tabline Configuration
Show listed buffers in the tabline using the provided helper function:

```vim
set showtabline=2
set tabline=%!simple_popup#buffer_tabline()
```

### Plugin Command Keymaps
Mappings for the buffer menu and search functionality:

```vim
" Open buffer menu
nnoremap <leader><leader><leader> <cmd>BufferMenu<cr>

" Search buffer by name (type name after the space)
nnoremap <leader><leader>s :BufferMenu 

" Search text across files via grep (type name after the space)
nnoremap <leader><leader><C-F> :SearchAcrossFiles 
```

### Popup Feature Keymaps
Mappings for internal Vim lists and command outputs:

```vim
" View messages in a popup
nnoremap <leader>msg <cmd>PopupExTail messages<cr>

" View key mappings
nnoremap <leader>map <cmd>PopupEx map<cr>

" View registers
nnoremap <leader>reg <cmd>PopupEx registers<cr>

" View Command-line history
nnoremap <leader>history <cmd>PopupExTail history<cr>

" View undolist
nnoremap <leader>undo <cmd>PopupExTail undolist<cr>

" Interactive jump list
nnoremap <leader>jumps <cmd>PopupJumps<cr>

" Interactive change list
nnoremap <leader>changes <cmd>PopupChanges<cr>

" View autocmds
nnoremap <leader>autocmd <cmd>PopupEx autocmd<cr>
```

### System Popup Keymaps
Execute external scripts or commands and view results:

```vim
" Example: Run an awk script on a file
nnoremap <leader>af <cmd>PopupSystem awk -f ~/script.awk ~/temp.txt<cr>
```

---

## Navigation within Popups
When a popup is open (using the default filter), you can use the following keys:

| Key | Action |
| :--- | :--- |
| `j` / `k` | Move cursor down/up |
| `ctrl-d` / `ctrl-u` | Half-page scroll down/up |
| `ctrl-f` / `ctrl-b` | Full-page scroll down/up |
| `<space>` / `u` | Scroll down/up |
| `g` / `G` | Jump to start/end |
| `q` | Close popup |
| `v` / `V` / `ctrl-v` | Enter Visual modes (Selection is functional but **not highlighted**) |
| `y` | yank selected block |

> [!NOTE]
> Currently, visual selection (v, V, C-v) does not display highlighting due to Vim's popup window limitations. However, the selection and yanking functions work as expected.

