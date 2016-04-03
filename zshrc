set INC_APPEND_HISTORY
# Paths
# ------------
# Export paths before sourcing anything
# Fixes colors for lxde-terminal. Useful for vim colorschemes
export TERM=xterm-256color
export GOROOT=/opt/go
export GOPATH=/opt/go_pkg
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export PATH=$PATH:/opt/eclipse
export PATH=$PATH:${HOME}/.dasht/bin
# Virtualenv
export WORKON_HOME=${HOME}/.virtualenvs
# Virtualenv
export PROJECT_HOME=${HOME}/Devel
export EDITOR=nvim
export PYTHONSTARTUP=~/.pythonrc

# Variables shared by personal install scripts.
# Potentially replace installs with submodules for antigen
export NVIM_DIR=${HOME}/.config/nvim
export ANTIGEN_PATH=${HOME}/.antigen/antigen.zsh

# Ease of use
export dotfiles=${HOME}/.dotfiles
export priv=${HOME}/.priv
export plugged=${NVIM_DIR}/plugged

# Wrk
export NODE_PROJECTS_DIR=${HOME}/repos/lab/repos

# Antigen
source $ANTIGEN_PATH
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle djui/alias-tips

antigen-use oh-my-zsh
antigen theme robbyrussell/oh-my-zsh themes/agnoster

antigen apply

# External scripts
# ------------
# Source these before our own `bindkeys` so that we can override stuff
# ------------
autoload bashcompinit && bashcompinit
scripts=${HOME}/.scripts
scripts=(
  ${HOME}/.fzf.zsh
  $scripts/fzf/shell/key-bindings.zsh
  ${HOME}/.dotfiles/fzf-helpers.zsh
  $scripts/i3_completion.sh
  /usr/local/bin/aws_zsh_completer.sh
  $scripts/nvm/nvm.sh
)

for script in $scripts; do
  if [ -f $script ]; then
    source $script
  else
    echo "tried sourcing ${script} but it was not found"
  fi
done

# Bindings
# ------------
# Find all options:                 zle -la
# To find out how a key is mapped:  bindkey <key>
# http://www.csse.uwa.edu.au/programming/linux/zsh-doc/zsh_19.html
#
# How to make custom widgets:
# http://sgeb.io/articles/zsh-zle-closer-look-custom-widgets/
# http://dougblack.io/words/zsh-vi-mode.html
# Also for visual vi-mode see: http://stackoverflow.com/a/13881077/2966951
#
# Modes: viins, vicmd

# Set vi-mode
bindkey -v

# By default, there is a 0.4 second delay after you hit the <ESC>
# key and when the mode change is registered. This results in a
# very jarring and frustrating transition between modes. Let's reduce
# this delay to 0.1 seconds.
export KEYTIMEOUT=1

# Move to the end of the line and exclude whitespace
end-of-line-no-whitespace() {
    zle vi-end-of-line
    zle vi-backward-word-end
}
zle -N end-of-line-no-whitespace

zle-line-init zle-keymap-select() {
  case $KEYMAP in
    viins|main)  print -nR $'\e[5 q';;
    vicmd)       print -nR $'\e[2 q';;
  esac
}
zle -N zle-line-init
zle -N zle-keymap-select

# When a new command is entered, return to the block cursor
zle-line-finish () {
  print -nR $'\e[2 q'
}
zle -N zle-line-finish

noop () {}
zle -N noop

# Paste from clipboard
vi-append-x-selection () {
  RBUFFER="$(xclip -o)$RBUFFER"
}
zle -N vi-append-x-selection

tmux-copy-mode() {
  if [ -n "$TMUX" ]; then
    tmux copy-mode
  fi
}
zle -N tmux-copy-mode

# Key bindings. Wanna find weird keycodes? use cat
# Fix backspace delete in vi-mode
# http://www.zsh.org/mla/users/2009/msg00812.html
bindkey "^?" backward-delete-char
# Movement bindings
bindkey -M vicmd q vi-backward-word
bindkey -M vicmd 0 noop
bindkey -M vicmd Q vi-beginning-of-line
bindkey -M vicmd $ noop
bindkey -M vicmd W end-of-line-no-whitespace

bindkey -M vicmd p vi-append-x-selection
bindkey -M vicmd P vi-append-x-selection

bindkey -M vicmd v tmux-copy-mode

# Reverse scrolling shift+tab
bindkey -M menuselect '^[[Z' reverse-menu-complete
# Aliases
# ------------
alias cd.="cd .."
alias cd..="cd ../.."
alias cd...="cd ../../.."
alias h="history"
alias cd-="cd -"
alias ls='ls --color=auto --classify'
alias aptinstall="sudo apt-get install ${1}"
alias aptupgrade="sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade"
alias setxkbmapcaps="setxkbmap -option caps:swapescape"
alias open='xdg-open'
alias vi='nvim'
alias gs='git status'
alias gd='git diff'
alias gl='git log'
alias gbl='tig blame'
alias ga='git add'
alias gf='git fetch'
alias gr='git rebase'
alias gb='git branch -avv'
alias gc='fcheckout'
# Allows 256 colors as background in terminal, used for Vi
alias tmux="tmux -2"

# cd && ls
function chpwd() {
    emulate -L zsh
    ls
}

man() {
  # TODO: Add fzf helper and pipe to vim
  if [ $1 = '-k' ]; then
    apropos ${@:2}
  else
    command man ${1} > /dev/null
    if [ $? = 0 ]; then
      nvim -c 'set ft=man' -c "Man ${1}" -c 'nnoremap <buffer> q :q<cr>'
    fi
  fi
}

# Start a tmux session for new terminals. This does not apply if we're
# inside a tmux session already or if tmux is not installed.
start-tmux-if-exist() {
  if [ -z $TMUX ]; then
    hash tmux
    if [ $? = 0 ]; then
      tmux
    fi
  fi
}

if [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
    echo 'Using Linux zshrc settings...'
    setxkbmap -option caps:swapescape
    start-tmux-if-exist

elif [[ "$(uname)" == "Darwin" ]]; then
    echo 'Using Mac OS zshrc settings...'
    # Use GNU coreutils instead of bsd ones
    export PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:$PATH"

else
    echo 'Unknown OS' $(uname)
fi

if [[ "$DESKTOP_SESSION" == "cinnamon" ]]; then
  echo 'Using cinnamon settings...'
  alias lock='cinnamon-screensaver-command -l'
elif [ "$DESKTOP_SESSION" = "i3" ]; then
  echo 'Using i3...'
  alias lock=i3lock
  keychain $HOME/.ssh/id_rsa
  source $HOME/.keychain/$HOST-sh
fi

