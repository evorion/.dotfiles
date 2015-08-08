##################################
# Own ease of use paths
##################################
export dotfiles=~/.dotfiles
export plugged=~/.vim/plugged
##################################

# Z directory auto completion
source $dotfiles/scripts/z.sh

##################################
# Aliases
##################################
alias sh="bash"
alias gno="gnome-open"
alias reboot="sudo reboot"
alias cd.="cd .."
alias cd..="cd ../.."
alias cd...="cd ../../.."
alias ls='ls --color=auto --classify'

alias aptupgrade="sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade"
# Swaps caps with esc
alias xkbmapcaps="setxkbmap -option caps:swapescape"
# Runs dmenu
alias ddmenu="dmenu_run -fn '-*-fixed-*-*-*-*-20-*-*-*-*-*-*-*' -l 5 -i"
alias vi='nvim'
alias gvi='/opt/nvim-qt/nvim-qt'
alias example=bro
# Allows 256 colors as background in terminal, used for Vi
alias tmux="tmux -2"

if [ $DESKTOP_SESSION == "xubuntu" ]; then
    alias sleepnow="xfce4-session-logout -s"
fi

##################################
# Terminal crap
##################################
# Fixes colors for lxde-terminal
export TERM="xterm-256color"
export EDITOR=gvi
export PYTHONSTARTUP=~/.dotfiles/rcfiles/pythonrc

##################################
# Custom installations
##################################
# Golang
export GOROOT=/opt/go
export GOPATH=/opt/go_pkg
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Eclipse
export PATH=$PATH:/opt/eclipse

##################################
# Virtualenvwrapper
##################################
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source /usr/local/bin/virtualenvwrapper.sh

##################################
# Custom functions
##################################
function cd() {
  if [ "$#" == 0 ]; then
    builtin cd "$HOME" && ls
  else
    builtin cd "$*" && ls
  fi
}

function google() {
    search=""
    echo "Googling: $@"
    for term in $@; do
        search="$search%20$term"
    done

    if type "google-chrome" > /dev/null
    then
        executable="google-chrome"
    elif type "chromium-browser" > /dev/null
    then
        executable="chromium-browser"
    elif type "firefox" > /dev/null
    then
        executable="firefox"
    fi

    if $executable
    then
        $executable "http://www.google.com/search?q=$search"
    else
        echo "Install google-chrome, chromium or firefox to use this command"
    fi
}

# Git show branch colored
PS1="\[$GREEN\]\t\[$RED\]-\[$BLUE\]\u\[$YELLOW\]\[$YELLOW\]\w\[\033[m\]\[$MAGENTA\]\$(__git_ps1)\[$WHITE\]\$ "

# nvi bash completion
[[ -r $NVM_DIR/bash_completion ]] && source $NVM_DIR/bash_completion

