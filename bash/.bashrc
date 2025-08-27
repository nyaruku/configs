#
# ~/.bashrc
# Default Bash Config
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

#
# Custom Bash Config 
#

alias ll='ls -lha --color=auto'
alias ls='ls -a --color=auto'
alias df='df -h'
alias treed='tree -d'
aur() {
    if [ -z "$1" ]; then
        echo "Usage: aurget <package-name> [clone-path]"
        return 1
    fi

    pkg="$1"
    clone_path="${2:-$pkg}"  # If no second argument, use the package name as the clone path

    echo "Cloning package '$pkg' into '$clone_path'..."
    git clone --depth=1 "https://aur.archlinux.org/${pkg}.git" "$clone_path" && cd "$clone_path" && makepkg -si
}

# ml_blau cursor
export GTK_CURSORS=ml_blau

