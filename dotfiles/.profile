# https://superuser.com/questions/789448/choosing-between-bashrc-profile-bash-profile-etc

export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=100000
export HISTFILE=100000
shopt -s histappend

export CLICOLOR=1

export HOMEBREW_NO_GITHUB_API=1
export HOMEBREW_NO_ANALYTICS=1

export PATH="$HOME/bin:$HOME/.cargo/bin:$PATH"

alias src='cd ~/src'

alias ls='ls --color=auto'
alias l='ls'
alias ll='ls -l'
alias la='ls -la'
alias lh='ls -lh'

