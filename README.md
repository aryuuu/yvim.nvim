## JSON/YAML Navigation

### Installation

```viml
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'aryuuu/yvim.nvim'
```

### How to use
Pick your favorite remaps and just put em on!  Put this in your `ftplugin`
folder.  Here is an example of mine (I have copied and pasted it below for
convenience):

Yes I did use the arrow keys because I have them nearish the home row on my
[Kinesis Advantage 2](https://bit.ly/primeagen-adv2).  I never use them, might
as well make them useful for something!

```viml
nnoremap <left> :lua require("yvim").to_parent()<CR>
nnoremap <right> :lua require("yvim").descend()<CR>
nnoremap <up> :lua require("yvim").prev_sibling()<CR>
nnoremap <down> :lua require("yvim").next_sibling()<CR>
```


```viml
nnoremap <left> :lua require("jvim").to_parent()<CR>
nnoremap <right> :lua require("jvim").descend()<CR>
nnoremap <up> :lua require("jvim").prev_sibling()<CR>
nnoremap <down> :lua require("jvim").next_sibling()<CR>
```


