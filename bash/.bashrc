#
# ~/.bashrc
# Default Bash Config
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls -a --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

#
# Custom Bash Config 
#

alias ll='ls -lha --color=auto'
