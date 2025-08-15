# My Dotfiles

Универсальный набор конфигураций для Ubuntu с фокусом на Zsh, Neovim, Go.

## Структура

```
dotfiles/
├── install.sh         # Скрипт установки
├── zsh/
│   └── .zshrc         # Конфигурация Zsh и Zinit
└── nvim/
    ├── init.lua       # Конфиг Neovim с LazyVim
    └── lua/
        ├── plugins/   # Плагины (Go, Markdown, Extras)
        └── core/      # Настройки Mason, LSP и др.
```

## Возможности

- **Zsh**
  - История команд 10 000, SHARE_HISTORY
  - Подсветка в стиле TokyoNight
  - Git-подсказки, быстрые переходы по каталогам (`z`)
  - Zinit с выбором темы (`typewritten`, `pure`, `spaceship`, `geometry`, `p10k`)

- **Neovim**
  - LazyVim + Lazy.nvim
  - Цветовая схема TokyoNight
  - Mason с фиксированными commit’ами
  - Оптимизация rtp (отключение ненужных встроенных плагинов)
  - Поддержка Go, Markdown, JSON, YAML, Protobuf

- **Go**
  - Версия Go: 1.24.2
  - Инструменты: gopls, golangci-lint, delve, revive, gofumpt

- **Rust**
  - Установка через rustup

- **Системные утилиты**
  - Ripgrep, fd-find, Node.js, Python3 + venv, build-essential

## Установка

```bash
git clone https://github.com/just-a-developer-man/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

Скрипт установит:
- Системные зависимости
- Neovim, Go, Rust
- Zsh и Zinit
- Создаст символические ссылки
- Установит Go-инструменты
- Синхронизирует плагины Neovim

## Настройка

- Zsh: редактируем `zsh/.zshrc`
- Neovim: редактируем `nvim/init.lua` и файлы в `nvim/lua/plugins/` и `nvim/lua/core/`

### Переключение темы Zsh

```bash
ZSH_THEME="pure"
source ~/.zshrc
```

## Обновление

```bash
cd ~/dotfiles
git pull
nvim --headless +'Lazy sync' +qa
export PATH=$PATH:/usr/local/go/bin:$(go env GOPATH)/bin
for tool in golang.org/x/tools/gopls@latest \
            github.com/mgechev/revive@latest \
            github.com/go-delve/delve/cmd/dlv@latest \
            github.com/golangci/golangci-lint/cmd/golangci-lint@latest \
            mvdan.cc/gofumpt@latest; do
    go install $tool
done
```
