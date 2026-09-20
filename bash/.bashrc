#
# ~/.bashrc
# Default Bash Config
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

eval "$(starship init bash)"

alias ll='ls -lha --color=auto'
alias l='ls -lha --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ls='ls -a --color=auto'
alias df='df -h'
alias treed='tree -d'
alias emacs='emacs -nw' # emacs in cli mode without arg
alias sue='sudoedit'
alias gittree='git log --all --graph --pretty=format:"%C(yellow)%h%C(reset) %C(green)%an%C(reset) %C(cyan)%ad%C(reset) %C(auto)%d%C(reset) %s" --date=format:"%Y-%m-%d %H:%M" --color'
alias gits='clear;pwd;git status'
alias spotify='LD_PRELOAD=~/git/spotifywm/spotifywm.so spotify'
alias ff='fastfetch'
alias nv='nvim'
#alias xmode="env -u WAYLAND_DISPLAY"
alias xmode='env -u WAYLAND_DISPLAY GDK_BACKEND=x11 QT_QPA_PLATFORM=xcb SDL_VIDEODRIVER=x11'
alias gamma="gammastep -l 0:0 -g 5"
alias zen="zen-browser"
alias vim="nvim"
alias vi="nvim"

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

export GTK_CURSORS=breeze_cursors
export XCURSOR_THEME=breeze_cursors
export XCURSOR_SIZE=24

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

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Add all private keys in ~/.ssh, skip .pub files
for key in ~/.ssh/*; do
    if [[ -f "$key" && "${key##*.}" != "pub" ]]; then
        ssh-add "$key" 2>/dev/null
    fi
done

#export EGL_PLATFORM=eglstream
#export __GLX_VENDOR_LIBRARY_NAME=nvidia
#export __GL_VENDOR_LIBRARY_NAME=NVIDIA
#export __VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json

export QT_QPA_PLATFORMTHEME=qt6ct
export PATH="$HOME/.npm-global/bin:$PATH"

# ALCOM
export WEBKIT_DISABLE_COMPOSITING_MODE=1

# cargo
. "$HOME/.cargo/env"
export PATH="$HOME/.cargo/bin:$PATH"

source '/home/railgun/.bash_completions/open-webui.sh'

# pnpm
export PNPM_HOME="/root/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
