#!/usr/bin/env zsh

### --- Основное ---
export ZSH_DISABLE_COMPFIX=true
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#565f89'   # серо-фиолетовый

# История
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000

setopt APPEND_HISTORY          # добавлять новые команды в файл
setopt INC_APPEND_HISTORY      # сразу записывать команды
setopt SHARE_HISTORY           # делиться историей между сессиями
setopt HIST_IGNORE_DUPS        # игнорировать повторяющиеся команды

# Поддержка цветов
autoload -U colors && colors
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS="di=34:ln=36:so=35:pi=33:ex=32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"

### --- Zinit ---
if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
  mkdir -p ~/.zinit
  git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
fi
source ~/.zinit/bin/zinit.zsh

### --- Выбор темы ---
# Доступные: pure, typewritten, spaceship, geometry, p10k
ZSH_THEME="typewritten"

case $ZSH_THEME in
  pure)
    zinit ice pick"async.zsh" src"pure.zsh"
    zinit light sindresorhus/pure
    ;;
  typewritten)
    zinit light reobin/typewritten
    ;;
  spaceship)
    zinit light spaceship-prompt/spaceship-prompt
    ;;
  geometry)
    zinit light geometry-zsh/geometry
    ;;
  p10k)
    zinit light romkatv/powerlevel10k
    ;;
esac

### --- Плагины ---
# Автодополнения
zinit light zsh-users/zsh-completions
# Подсказки справа (серый цвет в стиле tokyonight)
zinit light zsh-users/zsh-autosuggestions
# Подсветка ввода
zinit light zsh-users/zsh-syntax-highlighting
# Быстрые переходы по каталогам
zinit light agkozak/zsh-z
# Git (как в oh-my-zsh)
zinit snippet OMZP::git

### --- Tokyonight стили подсветки ---
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
typeset -A ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[command]='fg=#7aa2f7'     # голубой
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#bb9af7'     # фиолетовый
ZSH_HIGHLIGHT_STYLES[alias]='fg=#bb9af7'
ZSH_HIGHLIGHT_STYLES[function]='fg=#7dcfff'
ZSH_HIGHLIGHT_STYLES[option]='fg=#e0af68'      # золотой
ZSH_HIGHLIGHT_STYLES[argument]='fg=#9ece6a'    # зелёный
ZSH_HIGHLIGHT_STYLES[path]='fg=#73daca'
ZSH_HIGHLIGHT_STYLES[default]='fg=#c0caf5'     # светлый текст
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f7768e' # красный

### --- Удобные алиасы ---
alias ls='ls --color=auto -hF'
alias ll='ls -alF'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'

# Настройка Go bin и Neovim
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"
export GOPATH=$HOME/go
export EDITOR='nvim'
export VISUAL='nvim'

### --- Завершение ---
autoload -Uz compinit
compinit -u

