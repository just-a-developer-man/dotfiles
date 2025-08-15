#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="https://github.com/just-a-developer-man/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

GO_VERSION="1.24.2"

GO_TOOLS=(
  golang.org/x/tools/gopls@latest
  github.com/mgechev/revive@latest
  github.com/go-delve/delve/cmd/dlv@latest
  github.com/golangci/golangci-lint/cmd/golangci-lint@latest
  mvdan.cc/gofumpt@latest
)

command_exists() { command -v "$1" >/dev/null 2>&1; }

install_go_fixed() {
  if command_exists go && [[ "$(go version | awk '{print $3}')" == "go$GO_VERSION" ]]; then
    echo "✅ Go $GO_VERSION already installed"
    return
  fi
  echo "📦 Installing Go $GO_VERSION..."
  GO_TAR="go${GO_VERSION}.linux-amd64.tar.gz"
  if [ ! -f "$GO_TAR" ]; then
    curl -fsSL -O "https://go.dev/dl/${GO_TAR}"
  fi
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "$GO_TAR"
  export PATH=$PATH:/usr/local/go/bin:$(go env GOPATH)/bin
}

install_latest_rust() {
  if command_exists rustc; then
    echo "✅ Rust already installed"
    return
  fi
  echo "📦 Installing latest Rust..."
  curl -fsSL https://sh.rustup.rs | sh -s -- -y
  export PATH="$HOME/.cargo/bin:$PATH"
}

install_lazygit() {
  if command_exists lazygit; then
    echo "✅ LazyGit already installed"
    return
  fi
  echo "📦 Installing latest LazyGit..."
  LAZYGIT_VERSION=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" |
    grep -Po '"tag_name": *"v\K[^"]*')
  curl -fsSL -o lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar -xzf lazygit.tar.gz lazygit
  sudo install -Dm755 lazygit /usr/local/bin/lazygit
  rm -f lazygit lazygit.tar.gz
}

install_dotfiles() {
  
# required
  if [[ -d "$HOME/.config/nvim" ]]; then
    echo "⚠️ Backing up existing Neovim config..."
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
  fi
  [[ -d "$HOME/.local/share/nvim" ]] && mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.bak"
  [[ -d "$HOME/.local/state/nvim" ]] && mv "$HOME/.local/state/nvim" "$HOME/.local/state/nvim.bak"
  [[ -d "$HOME/.cache/nvim" ]] && mv "$HOME/.cache/nvim" "$HOME/.cache/nvim.bak"

  echo "📥 Cloning/updating dotfiles..."
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  else
    git -C "$DOTFILES_DIR" pull
  fi

  ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
  mkdir -p "$HOME/.config/nvim"
  ln -sf "$DOTFILES_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"
  ln -sf "$DOTFILES_DIR/nvim/lua" "$HOME/.config/nvim/lua"
}

install_zsh_and_zinit() {
  echo "⚙️ Installing Zsh and Zinit..."
  sudo apt install -y zsh
  if ! grep -q "$(command -v zsh)" /etc/shells; then
    echo "$(command -v zsh)" | sudo tee -a /etc/shells
  fi
  chsh -s "$(command -v zsh)" "$USER"
  sudo chsh -s "$(command -v zsh)" root

  if [[ ! -d "$HOME/.zinit" ]]; then
    mkdir -p "$HOME/.zinit"
    git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.zinit/bin"
  fi
}

install_go_tools() {
  echo "🔧 Installing Go tools..."
  export PATH=$PATH:$(go env GOPATH)/bin
  for tool in "${GO_TOOLS[@]}"; do
    if ! command_exists "$(basename "$tool")"; then
      go install "$tool"
    else
      echo "✅ $(basename "$tool") already installed"
    fi
  done
}

install_neovim_plugins() {
  if command_exists nvim; then
    echo "📦 Installing Neovim plugins..."
    nvim --headless +'Lazy sync' +qa
  else
    echo "⚠️ Neovim not installed, skipping plugin sync"
  fi
}

# -------------------------------
# Main
# -------------------------------
echo "🚀 Updating system..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl git nodejs npm build-essential ripgrep fd-find python3-dev python3-venv

install_lazygit
install_go_fixed
install_latest_rust
install_zsh_and_zinit
install_dotfiles
install_go_tools
install_neovim_plugins

echo "✅ Setup complete!"
exec zsh -l
