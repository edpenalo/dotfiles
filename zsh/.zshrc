# Has weird character width
# Example:
#    is not a diamond
HAS_WIDECHARS="false"

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="bira"
plugins=(git zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

source /usr/share/nvm/init-nvm.sh

export ANDROID_HOME=~/Android/Sdk
export ASPNETCORE_ENVIRONMENT=Local

export PATH=$PATH:$HOME/.dotnet/tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

alias history="history 0"
