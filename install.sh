#!/bin/bash
# QuickInstall - A powerful script to quickly set up a complete development environment
# Author: remuzel
# License: MIT
# GitHub: https://github.com/remuzel/QuickInstall

set -e

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Helper functions for logging and UI
print_banner() {
  echo -e "${CYAN}"
  echo "  ___        _      _    ___           _        _ _ "
  echo " / _ \ _   _(_) ___| | _|_ _|_ __  ___| |_ __ _| | |"
  echo "| | | | | | | |/ __| |/ /| || '_ \/ __| __/ _\` | | |"
  echo "| |_| | |_| | | (__|   < | || | | \__ \ || (_| | | |"
  echo " \__\_\\\\__,_|_|\___|_|\_\___|_| |_|___/\__\__,_|_|_|"
  echo -e "${NC}"
  echo "A powerful development environment setup script"
  echo "=============================================="
  echo
}

log_info() {
  echo -e "${BLUE}INFO:${NC} $1"
}

log_success() {
  echo -e "${GREEN}SUCCESS:${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}WARNING:${NC} $1"
}

log_error() {
  echo -e "${RED}ERROR:${NC} $1"
}

log_section() {
  echo
  echo -e "${PURPLE}==== $1 ====${NC}"
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Configuration variables
ZSHRC_PATH="$HOME/.zshrc"
VIMRC_PATH="$HOME/.vimrc"
VIM_BUNDLE_DIR="$HOME/.vim/bundle"
ZSH_PLUGINS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Print banner and check if run as root
print_banner

if [ "$(id -u)" = "0" ]; then
  log_warning "This script should not be run as root"
  read -p "Are you sure you want to continue? (y/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_warning "Installation aborted by user"
    exit 1
  fi
fi

# Check system requirements
log_section "System Check"
log_info "Checking system requirements..."

# Check for git
if ! command_exists git; then
  log_error "Git is required but not installed."
  read -p "Would you like to install Git now? (y/n): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command_exists apt-get; then
      sudo apt-get update && sudo apt-get install -y git
    elif command_exists brew; then
      brew install git
    elif command_exists dnf; then
      sudo dnf install -y git
    elif command_exists yum; then
      sudo yum install -y git
    else
      log_error "Could not install Git. Please install it manually and run this script again."
      exit 1
    fi
  else
    log_error "Git is required. Aborting."
    exit 1
  fi
fi

# Check for curl
if ! command_exists curl; then
  log_error "Curl is required but not installed."
  read -p "Would you like to install Curl now? (y/n): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command_exists apt-get; then
      sudo apt-get update && sudo apt-get install -y curl
    elif command_exists brew; then
      brew install curl
    elif command_exists dnf; then
      sudo dnf install -y curl
    elif command_exists yum; then
      sudo yum install -y curl
    else
      log_error "Could not install Curl. Please install it manually and run this script again."
      exit 1
    fi
  else
    log_error "Curl is required. Aborting."
    exit 1
  fi
fi

# Prompt for confirmation
log_section "Installation Confirmation"
echo "This script will set up your development environment with:"
echo "  - ZSH with Oh-My-ZSH and PowerLevel10k theme"
echo "  - Enhanced Vim configuration with useful plugins"
echo "  - Git configuration and aliases"
echo "  - Additional useful tools and utilities"
echo
read -p "Continue with installation? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  log_warning "Installation aborted by user"
  exit 1
fi

# Install zsh if it's not installed
if ! command_exists zsh; then
  log_info "ZSH not found. Installing..."
  if command_exists apt-get; then
    sudo apt-get update
    sudo apt-get install -y zsh
  elif command_exists brew; then
    brew install zsh
  elif command_exists dnf; then
    sudo dnf install -y zsh
  elif command_exists yum; then
    sudo yum install -y zsh
  else
    log_warning "Could not install ZSH automatically. Please install it manually and run this script again."
    exit 1
  fi
  log_success "ZSH installed"
else
  log_info "ZSH already installed"
fi

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log_info "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  log_success "oh-my-zsh installed"
else
  log_info "oh-my-zsh already installed"
fi

# Install and set the PowerLevel10k theme for zsh
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
  log_info "Installing PowerLevel10k theme for ZSH..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  log_success "PowerLevel10k theme installed"
else
  log_info "PowerLevel10k theme already installed"
fi

log_info "Configuring ZSH theme..."
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i "" "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/" $ZSHRC_PATH
else
  sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/" $ZSHRC_PATH
fi
log_success "ZSH theme configured"

# Set useful aliases/functions in ZSHRC_PATH
log_info "Setting up helpful aliases and functions..."
grep -q "# ===AUTOMATICALLY ADDED===" "$ZSHRC_PATH" || cat >> $ZSHRC_PATH <<- EOM
# ===AUTOMATICALLY ADDED===
# Helpful aliases
alias zshconfig="vim \${ZSHRC_PATH}"
alias zshreload="source \${ZSHRC_PATH}"
alias ll="ls -lah"
alias la="ls -A"
alias l="ls -CF"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Git aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"

# Enhanced clear function
function cls() {
  clear;
  if git rev-parse --git-dir > /dev/null 2>&1; then
    git status;
  else
    ls;
  fi
}

# Extract function - handles various compressed file formats
extract() {
  if [ -f \$1 ] ; then
    case \$1 in
      *.tar.bz2)   tar xjf \$1     ;;
      *.tar.gz)    tar xzf \$1     ;;
      *.bz2)       bunzip2 \$1     ;;
      *.rar)       unrar e \$1     ;;
      *.gz)        gunzip \$1      ;;
      *.tar)       tar xf \$1      ;;
      *.tbz2)      tar xjf \$1     ;;
      *.tgz)       tar xzf \$1     ;;
      *.zip)       unzip \$1       ;;
      *.Z)         uncompress \$1  ;;
      *.7z)        7z x \$1        ;;
      *)           echo "'\\$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'\\$1' is not a valid file"
  fi
}
# =========================
EOM
log_success "Aliases and functions configured"

# Install zsh plugins
log_info "Installing ZSH plugins..."
ZSH_PLUGINS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

# zsh-syntax-highlighting
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
  log_success "zsh-syntax-highlighting installed"
else
  log_info "zsh-syntax-highlighting already installed"
fi

# zsh-autosuggestions
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
  log_success "zsh-autosuggestions installed"
else
  log_info "zsh-autosuggestions already installed"
fi

# Update plugins in .zshrc
log_info "Updating ZSH plugins configuration..."
if grep -q "^plugins=" "$ZSHRC_PATH"; then
  sed -i 's/^plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' "$ZSHRC_PATH"
else
  echo 'plugins=(git zsh-syntax-highlighting zsh-autosuggestions)' >> "$ZSHRC_PATH"
fi
log_success "ZSH plugins configured"

# Install the vim configurations
log_info "Installing vim configurations..."

# Install the pathogen.vim plugin manager
if [ ! -f ~/.vim/autoload/pathogen.vim ]; then
  log_info "Installing the pathogen plugin manager..."
  mkdir -p ~/.vim/autoload ~/.vim/bundle
  curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
  log_success "Pathogen installed"
else
  log_info "Pathogen already installed"
fi

# Install vim plugins
log_info "Installing vim plugins..."
VIM_BUNDLE_DIR="$HOME/.vim/bundle"

# Install gruvbox (colorscheme)
if [ ! -d "$VIM_BUNDLE_DIR/gruvbox" ]; then
  git clone https://github.com/morhetz/gruvbox.git "$VIM_BUNDLE_DIR/gruvbox"
  log_success "Gruvbox colorscheme installed"
else
  log_info "Gruvbox colorscheme already installed"
fi

# Backup existing .vimrc
if [ -f ~/.vimrc ]; then
  BACKUP_FILE=~/.vimrc.backup.$(date +%Y%m%d%H%M%S)
  log_warning "Backing up existing .vimrc to $BACKUP_FILE"
  cp ~/.vimrc "$BACKUP_FILE"
fi

# Setup the ~/.vimrc
log_info "Setting up ~/.vimrc..."
cat > ~/.vimrc <<- EOM
execute pathogen#infect()
syntax on
filetype plugin indent on

" Common settings
set expandtab                       " tabs are spaces
set tabstop=2                       " number of visual spaces per TAB
set softtabstop=2                   " number of spaces in tab when editing
set shiftwidth=2                    " Spaces to use for autoindenting
set breakindent                     " Wrap lines at same indent level
set autoindent                      " always turn on indentation
set smartindent
set backspace=indent,eol,start      " proper backspace behavior

" UI Configuration
syntax on
autocmd BufWritePre * %s/\s\+$//e   " Remove trailing whitespace on save
set number                          " Show line numbers
set relativenumber                  " Show relative line numbers
set showcmd                         " show command in bottom bar
set cursorline                      " highlight current line
set wildmenu                        " visual autocomplete for command menu
set wildmode=longest,full           " Enable file autocomplete in command mode
set lazyredraw                      " redraw only when we need to
set showmatch                       " highlight matching [{()}]
set scrolloff=15                    " always leave 15 spaces when scrolling
set linebreak                       " don't wrap words
set timeoutlen=300 ttimeoutlen=10   " Eliminate delay when changing mode
set splitbelow                      " horizontal split opens below
set splitright                      " Vertical split opens to the right
set incsearch                       " search as characters are entered
set hlsearch                        " highlight matches
set ignorecase                      " ignore case when searching
set smartcase                       " but case-sensitive if expression contains a capital letter
set signcolumn=yes                  " Always show the sign column
set mouse=a                         " Enable mouse support
set clipboard=unnamed               " Use system clipboard
set hidden                          " Allow switching buffers without saving
set history=1000                    " Store more history
set undolevels=1000                 " More undo levels
set title                           " Change the terminal's title
set visualbell                      " Use visual bell instead of beeping
set noerrorbells                    " Don't beep
set foldmethod=indent               " Fold based on indentation
set foldlevelstart=99               " Start with all folds open

" Theme & Colors
autocmd vimenter * ++nested colorscheme gruvbox
set background=dark                 " Setting dark mode
if exists('$TMUX')
  set termguicolors                 " Enable true colors support
endif

" Key mappings
let mapleader = " "                 " Use space as leader key
" Exit insert mode with 'jk'
inoremap jk <Esc>
" Quick save
nnoremap <leader>w :w<CR>
" Quick quit
nnoremap <leader>q :q<CR>
" Move between windows
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l
" Quick open NERDTree
nnoremap <leader>n :NERDTreeToggle<CR>
" Clear search highlight
nnoremap <leader>/ :nohlsearch<CR>
" Toggle relative numbers
nnoremap <leader>rn :set relativenumber!<CR>
EOM
log_success "Vim configuration created"

# Install vim plugins
log_info "Installing additional vim plugins..."
VIM_PLUGINS=(
  "https://github.com/tpope/vim-sensible.git"
  "https://github.com/preservim/nerdtree.git"  # Fixed the typo from "perservim" to "preservim"
  "https://github.com/junegunn/rainbow_parentheses.vim.git"
  "https://github.com/tpope/vim-surround.git"
  "https://github.com/tpope/vim-commentary.git"
  "https://github.com/jiangmiao/auto-pairs.git"
  "https://github.com/airblade/vim-gitgutter.git"
  "https://github.com/vim-airline/vim-airline.git"
  "https://github.com/vim-airline/vim-airline-themes.git"
)

for PLUGIN_URL in "${VIM_PLUGINS[@]}"; do
  PLUGIN_NAME=$(basename "$PLUGIN_URL" .git)
  if [ ! -d "$VIM_BUNDLE_DIR/$PLUGIN_NAME" ]; then
    git clone "$PLUGIN_URL" "$VIM_BUNDLE_DIR/$PLUGIN_NAME"
    log_success "$PLUGIN_NAME installed"
  else
    log_info "$PLUGIN_NAME already installed"
  fi
done

# Set up fzf for fuzzy finding
if ! command_exists fzf; then
  log_info "Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
  log_success "fzf installed"
else
  log_info "fzf already installed"
fi

# Setting up tmux configuration (if available)
if command_exists tmux; then
  log_section "TMUX Configuration"
  log_info "Setting up tmux configuration..."

  # Back up existing tmux.conf if it exists
  if [ -f "$HOME/.tmux.conf" ]; then
    log_warning "Backing up existing .tmux.conf to ~/.tmux.conf.backup.$TIMESTAMP"
    cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$TIMESTAMP"
  fi

  # Create tmux configuration
  cat > "$HOME/.tmux.conf" <<- EOM
# Improve colors
set -g default-terminal "screen-256color"

# Set scrollback buffer to 10000
set -g history-limit 10000

# Customize the status line
set -g status-fg green
set -g status-bg black

# Remap prefix from 'C-b' to 'C-a'
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Reload config file
bind r source-file ~/.tmux.conf \; display "Reloaded ~/.tmux.conf"

# Switch panes using Alt-arrow without prefix
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Enable mouse mode
set -g mouse on

# Don't rename windows automatically
set-option -g allow-rename off

# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1
EOM
  log_success "Tmux configuration created"
else
  log_info "Tmux not found. Skipping tmux configuration."
fi

# Configure git global settings if needed
log_section "Git Configuration"
if command_exists git; then
  # Check if git user name is set
  if [ -z "$(git config --global user.name)" ]; then
    log_info "Setting up git configuration..."
    read -p "Enter your git username: " GIT_USERNAME
    read -p "Enter your git email: " GIT_EMAIL

    git config --global user.name "$GIT_USERNAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global core.editor "vim"
    git config --global init.defaultBranch "main"
    git config --global pull.rebase true
    git config --global color.ui auto

    log_success "Git configuration completed"
  else
    log_info "Git is already configured with username: $(git config --global user.name)"
  fi
else
  log_warning "Git not found. Skipping git configuration."
fi

# Final setup and cleanup
log_section "Finalizing Installation"

# Create a cleanup script
log_info "Creating cleanup script..."
cat > "$HOME/quickinstall-cleanup.sh" <<- 'EOM'
#!/bin/bash
read -p "This will remove all QuickInstall configurations and revert to defaults. Are you sure? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Cleanup aborted"
  exit 1
fi

# Remove vim plugins and configuration
echo "Removing vim configurations..."
if [ -d "$HOME/.vim" ]; then
  rm -rf "$HOME/.vim"
fi
if [ -f "$HOME/.vimrc" ]; then
  rm -f "$HOME/.vimrc"
fi

# Remove Oh-My-ZSH and plugins
echo "Removing Oh-My-ZSH..."
if [ -d "$HOME/.oh-my-zsh" ]; then
  rm -rf "$HOME/.oh-my-zsh"
fi

# Clean .zshrc
if [ -f "$HOME/.zshrc" ]; then
  rm -f "$HOME/.zshrc"
fi

# Remove FZF
if [ -d "$HOME/.fzf" ]; then
  rm -rf "$HOME/.fzf"
fi

# Remove tmux config
if [ -f "$HOME/.tmux.conf" ]; then
  rm -f "$HOME/.tmux.conf"
fi

echo "Cleanup completed successfully. Please restart your terminal."
EOM

chmod +x "$HOME/quickinstall-cleanup.sh"
log_success "Cleanup script created at ~/quickinstall-cleanup.sh"

# Final touches
log_info "Setting ZSH as default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
  log_success "Default shell changed to ZSH"
else
  log_info "ZSH is already the default shell"
fi

# Create a summary of installed components
log_info "Creating installation summary..."
cat > "$HOME/quickinstall-summary.txt" <<- EOM
QuickInstall Summary
=====================
Installation date: $(date)

Components installed:
- ZSH and Oh-My-ZSH
- PowerLevel10k ZSH theme
- ZSH plugins: syntax-highlighting, autosuggestions
- Vim with Pathogen and plugins
- Custom terminal aliases and functions
$(command_exists fzf && echo "- FZF fuzzy finder")
$(command_exists tmux && echo "- Tmux configuration")

Configuration files:
- ZSH: $ZSHRC_PATH
- Vim: $VIMRC_PATH
$(command_exists tmux && echo "- Tmux: $HOME/.tmux.conf")

To update configuration:
- ZSH: Edit $ZSHRC_PATH or run 'zshconfig'
- Vim: Edit $VIMRC_PATH

To uninstall:
Run ~/quickinstall-cleanup.sh
EOM

log_success "Installation summary created at ~/quickinstall-summary.txt"

# Final success message
log_section "Installation Complete"
log_success "QuickInstall completed successfully!"
echo
echo "What's next?"
echo "  1. Restart your terminal or run 'source $ZSHRC_PATH' to apply changes"
echo "  2. When you first open a new terminal, PowerLevel10k will guide you through its setup"
echo "  3. Read the installation summary at ~/quickinstall-summary.txt"
echo "  4. If needed, uninstall using ~/quickinstall-cleanup.sh"
echo
echo "Enjoy your new development environment!"
