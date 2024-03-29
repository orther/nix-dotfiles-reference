# Emacs tramp mode compatibility
[[ $TERM == "tramp" ]] && unsetopt zle && PS1='$ ' && return

# initialize keychain: This can go below instant prompt so long as -q is enabled and --eval is disabled
eval $(keychain -q --eval)

# Hook direnv
emulate zsh -c "$(direnv export zsh)"

# Enable Powerlevel10k instant prompt. Should stay at the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable direnv
emulate zsh -c "$(direnv hook zsh)"

# Set dircolors
export CLICOLOR=1
eval $( dircolors -b $HOME/.dircolors )

# Completion
autoload -U compinit 
compinit

# Completion options from zsh lovers
zstyle ':completion:*' menu select

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b' 

zstyle ':completion::complete:*' gain-privileges 1
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Host completion copied from grml
[[ -r ~/.ssh/config ]] && _ssh_config_hosts=(${${(s: :)${(ps:\t:)${${(@M)${(f)"$(<$HOME/.ssh/config)"}:#Host *}#Host }}}:#*[*?]*}) || _ssh_config_hosts=()
[[ -r ~/.ssh/known_hosts ]] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
[[ -r /etc/hosts ]] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()

hosts=(
	$(hostname)
	"$_ssh_config_hosts[@]"
	"$_ssh_hosts[@]"
	"$_etc_hosts[@]"
	localhost
       )

zstyle ':completion:*:hosts' hosts $hosts

# Glob settings
setopt extendedglob

# Correction
# setopt correctall

# History
export HISTSIZE=2000
export HISTFILE="$HOME/.history" 
export SAVEHIST=$HISTSIZE
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt share_history

# Set emacs mode
bindkey -e

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[ShiftTab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"      beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"       end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"    overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}" backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"    delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"        up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"      down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"      backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"     forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"    beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"  end-of-buffer-or-history
[[ -n "${key[ShiftTab]}"  ]] && bindkey -- "${key[ShiftTab]}"  reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start {
		echoti smkx
	}
	function zle_application_mode_stop {
		echoti rmkx
	}
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# Control left/right for backward word/forward word
key[Control-Left]="${terminfo[kLFT5]}"
key[Control-Right]="${terminfo[kRIT5]}"

[[ -n "${key[Control-Left]}"  ]] && bindkey -- "${key[Control-Left]}"  backward-word
[[ -n "${key[Control-Right]}" ]] && bindkey -- "${key[Control-Right]}" forward-word

# Alt left/right for beginning-of-line/end-of-line
key[Alt-Left]="${terminfo[kLFT3]}"
key[Alt-Right]="${terminfo[kRIT3]}"

key[Alt-Left]="^[[1;3D"
key[Alt-Right]="^[[1;3C"

[[ -n "${key[Alt-Left]}"  ]] && bindkey -- "${key[Alt-Left]}"  beginning-of-line
[[ -n "${key[Alt-Right]}" ]] && bindkey -- "${key[Alt-Right]}" end-of-line

# Fish like history
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search

# Rationalize dot (... -> ../..)
rationalise-dot() {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+=/..
  else
    LBUFFER+=.
  fi
}

# Automatically expand dots
zle -N rationalise-dot
bindkey . rationalise-dot

# Colored output in man pages
man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}
# Edit current line with editor 
autoload edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Prompt configuration
source ~/.zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme
source ~/.zsh/plugins/powerlevel10k/config/p10k-lean.zsh

alias ls="ls --color=auto"
alias ll="ls -alh --color=auto"
alias l="ls --color=auto"

# Useful docker commands
# Can also append --filter="ancestor=tdw:bp-1.4.5a" to ignore running container
das () {
  docker kill $(docker ps -q)
}

dsh () {
  docker exec -i -t $1 /bin/bash
}

function _dsh(){
  containers=("${(@f)$(docker ps --format '{{.Names}}')}")
  compadd $containers
}

compdef _dsh dsh

em () {
  emacsclient $1 > /dev/null 2>&1 || emacs $1 &
}

# FZF
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Enable z.lua
eval "$(z --init zsh)"

# Set environmental variables
export EDITOR="nvim"

list-ec2 () {
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceType, State.Name, LaunchTime, PublicDnsName]' --output table
}

# Set environmental variables
export EDITOR="nvim"

home-upgrade () {
  niv -s $HOME/.config/nixpkgs/nix/sources.json update
  nix-channel --update
  home-manager switch
  nvim +PlugUpdate +qall &> /dev/null
  doom -y upgrade
}
