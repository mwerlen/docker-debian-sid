" File: _vimrc             
" Version: 1
" Author: Maxime Werlen
" Created: 30/12/2011


" Use Vim settings, rather then Vi settings (much better!).
set nocompatible

set laststatus=2

" Gestion des couleurs
if !has('gui_running')
  set t_Co=256
endif

" Load my color scheme 
colorscheme torte

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" I like 4 spaces for indenting
set shiftwidth=4

" I like 4 stops
set tabstop=4

" Spaces instead of tabs
set expandtab

" Always  set auto indenting on
set autoindent

" show the cursor position all the time
set ruler       

" Show  tab characters. Visual Whitespace.
set list
set listchars=tab:>.

" Set ignorecase on
set ignorecase

" showmatch: Show the matching bracket for the last ')'?
set showmatch

" Numérotation des lignes
set number

" Affichage d'une ligne du 90eme caractère
set colorcolumn=90

" Performance improvement
set hidden
set history=100

" Automatically wrap long lines
set wrap linebreak

" Default encoding to utf-8
set encoding=utf8
set fileencoding=utf-8

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern and disabling
" search with escape
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Set spelling in french
syn spell toplevel
set spell spelllang=en
set nospell

" Getting markdown file right
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
autocmd BufNewFile,BufReadPost *.prez set filetype=markdown
" autocmd BufEnter *.txt set spell
autocmd BufEnter *.md set spell

map <silent> <F7> "<Esc>:silent setlocal spell! spelllang=fr<CR>"

" Always works with system clipboard
set clipboard=unnamed

" Allow to force write
cmap w!! w !sudo tee > /dev/null %
