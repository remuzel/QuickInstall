#!/bin/bash

ZSHRC_PATH="~/.zshrc"

# Install oh-my-zsh
echo "Installing oh-my-zsh..."
sh -c "$(curl -fsSLhttps://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "...done"

# Install and set the PowerLevel10k theme for zsh
echo "Installing and setting up PowerLevel10k theme for ZSH..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
if [["$OSTYPE" == "darwin"* ]]; then
  sed -i "" "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/" $ZSHRC_PATH
else
  sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/" $ZSHRC_PATH

# Set useful aliases/functions in ZSHRC_PATH
cat >> $ZSHRC_PATH <<- EOM
# ===AUTOMATICALLY ADDED===
# Helpful aliases
alias zshconfig="vim ${ZSHRC_PATH}"
alias zshreload="source ${ZSHRC_PATH}"
function cls() {
  clear;
  if git rev-parse --git-dir > /dev/null 2>&1; then
    git status;
  else
    ls;
  fi
}
# =========================
EOM
source $ZSHRC_PATH
echo "...done"

# Install the pathogen.vim plugin manager
echo "Installing the pathogen plugin manager and setting up ~/.vimrc..."
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Setup the ~/.vimrc (WARN: This will overwrite any existing contents)
cat > ~/.vimrc <<- EOM
execute pathogen#infect()

" Common settings
set expandtab                       " tabs are spaces
set tabstop=2                       " number of visual spaces per TAB
set softtabstop=2                   " number of spaces in tab when editing
set shiftwidth=2                    " Spaces to use for autoindenting
set breakindent                     " Wrap lines at same indent level
set autoindent                      " always turn on indentation
set smartindent
set backspace=indent,eol,start      " proper backspace behavior

syntax on
autocmd BufWritePre * %s/\s\+$//e
set number
set showcmd                         " show command in bottom bar
set cursorline                      " highlight current line
set wildmenu                        " visual autocomplete for command menu
set wildmode=longest,full           " Enable file autocomplete in command mode
set lazyredraw                      " redraw only when we need to.
set showmatch                       " highlight matching [{()}]
set scrolloff=15                    " always leave 15 spaces when scrolling
set linebreak                       " don't wrap words
set timeoutlen=300 ttimeoutlen=10   " Eliminate delay when changing mode
set splitbelow                      " horizontal split opens below
set splitright                      " Vertical split opens to the right
set incsearch                       " search as characters are entered
set hlsearch                        " highlight matches
set signcolumn=yes                  " Always show the sign column

filetype plugin indent on
EOM

# Install vim plugins
cd ~/.vim/bundle && \
git clone https://github.com/tpope/vim-sensible.git
git clone https://github.com/perservim/nerdtree.git
cd -
echo "...done"
