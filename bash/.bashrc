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

if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
	GIT_PROMPT_VIRTUAL_ENV_AFTER_PROMPT=1
	source "$HOME/.bash-git-prompt/gitprompt.sh"
fi

alias ll='ls -lha --color=auto'
alias ls='ls -a --color=auto'
alias df='df -h'
alias treed='tree -d'
alias emacs='emacs -nw' # emacs in cli mode without arg
alias sue='sudoedit'
alias gittree='git log --graph --pretty=format:"%C(yellow)%h%C(reset) %C(green)%an%C(reset) %C(cyan)%ad%C(reset) %C(auto)%d%C(reset) %s" --date=format:"%Y-%m-%d %H:%M" --color'
alias gits='clear;pwd;git status'

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

nvim() {
    # If no file given, just run normal nvim
    if [ $# -eq 0 ]; then
        command nvim
        return
    fi

    for file in "$@"; do
        # If the file exists and is writable by the user, open normally
        if [ -w "$file" ] || [ ! -e "$file" ]; then
            command nvim "$file"
        else
            # If not writable (needs root), use sudoedit
            sudoedit "$file"
        fi
    done
}

# ml_blau cursor
export GTK_CURSORS=ml_blau
export EDITOR=nvim
export VISUAL=nvim
export LS_COLORS="\
di=01;34:\
ln=01;36:\
mh=00:\
pi=33:\
so=01;35:\
do=01;35:\
bd=01;33:\
cd=01;33:\
or=01;31:\
mi=00:\
su=01;31:\
sg=01;33:\
ca=00:\
tw=01;34:\
ow=01;34:\
st=01;34:\
ex=01;32"

export PATH=/home/railgun/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/var/lib/flatpak/exports/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl
export PATH=/home/railgun/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/var/lib/flatpak/exports/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl
