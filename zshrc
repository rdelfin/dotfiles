
# Path to your oh-my-zsh installation.
export ZSH=/home/rdelfin/.oh-my-zsh

ZSH_THEME="bira"

export ZSH_TMUX_AUTOSTART=true
export ZSH_TMUX_AUTOQUIT=false

ZSH_THEME_HG_PROMPT_PREFIX="%{$fg_bold[magenta]%}hg:(%{$fg[red]%}"
ZSH_THEME_HG_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_HG_PROMPT_DIRTY="%{$fg[magenta]%}) %{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_HG_PROMPT_CLEAN="%{$fg[magenta]%})"

plugins=(git tmux mercurial)

source $ZSH/oh-my-zsh.sh

export PATH=$PATH:/home/rdelfin/.gem/ruby/2.5.0/bin:
export PATH="$PATH:${KREW_ROOT:-$HOME/.krew}/bin"
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:/home/rdelfin/.local/bin
export PATH=$PATH:/usr/local/go/bin

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

bindkey '^R' history-incremental-pattern-search-backward

alias calc="bc"
alias vim="nvim"
alias vi="nvim"
alias please="sudo"
alias ll="ls -l -h"

export VISUAL='nvim'
export EDITOR=$VISUAL

alias prettyjson='python -m json.tool'
lessjson() {
    cat $1 | prettyjson | pygmentize -l javascript | less -R
}


phone-home() {
    mosh -p 55165 --ssh="ssh -p 283" home.rdelfin.com
}

fpath[1,0]=$HOME/.zsh/completion/

# bazel auto completion
fpath[1,0]=$HOME/.zsh/completion/
# This way the completion script does not have to parse Bazel's options
# repeatedly.  The directory in cache-path must be created manually.
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

compinit

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


export GPG_TTY=$(tty)

# azcopy
export AZCOPY_AUTO_LOGIN_TYPE=DEVICE

# Make FZF ignore unimportant folders
export FZF_DEFAULT_COMMAND='rg --files --follow --no-ignore-vcs --hidden -g "!{node_modules/*,.git/*,target/*,bzl-build/*,}"'
#compdef gt
###-begin-gt-completions-###
#
# yargs command completion script
#
# Installation: gt completion >> ~/.zshrc
#    or gt completion >> ~/.zprofile on OSX.
#
_gt_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" gt --get-yargs-completions "${words[@]}"))
  IFS=$si
  _describe 'values' reply
}
compdef _gt_yargs_completions gt
###-end-gt-completions-###


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# tabtab source for electron-forge package
# uninstall by removing these lines or running `tabtab uninstall electron-forge`
[[ -f /home/rdelfin/code/review-dashboard/node_modules/tabtab/.completions/electron-forge.zsh ]] && . /home/rdelfin/code/review-dashboard/node_modules/tabtab/.completions/electron-forge.zsh

export PATH="/home/rdelfin/.pixi/bin:$PATH"
