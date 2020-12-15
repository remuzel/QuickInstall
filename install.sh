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
syntax on
set number
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent
set smartindent
set showmatch
autocmd BufWritePre * %s/\s\+$//e
filetype plugin indent on
EOM

# Install vim plugins
cd ~/.vim/bundle && \
git clone https://github.com/tpope/vim-sensible.git
git clone https://github.com/perservim/nerdtree.git
cd -
echo "...done"
