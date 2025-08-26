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
