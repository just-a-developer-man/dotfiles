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

install_bin_tools() {
  sudo apt install -y ghex qemu-system qemu-user gdb gdb-multiarch gdbserver gcc gcc-multilib binwalk hexedit wxhexeditor flatpak

  sudo flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  sudo flatpak install flathub org.radare.iaito
}

setup_gnome_term_theme() {
  export GOGH_APPLY_SCRIPT=apply-colors.sh
  export TERMINAL=gnome-terminal
  export GOGH_NONINTERACTIVE=true
  export GOGH_USE_NEW_THEME=
  export SCRIPT=tokyo-night-storm.sh

  wget "https://github.com/Gogh-Co/Gogh/raw/master/$GOGH_APPLY_SCRIPT"
  wget "https://github.com/Gogh-Co/Gogh/raw/master/installs/$SCRIPT"

  chmod +x "$SCRIPT"
  bash "./$SCRIPT"

  rm -f "./$SCRIPT" "./$GOGH_APPLY_SCRIPT"
}

install_vs_code() {
  # Установка VS Code из snap
  echo "[*] Устанавливаю VS Code..."
  sudo snap install code --classic

  # Ждем пока snap обновит PATH (на всякий случай)
  sleep 2

  # Список расширений
  extensions=(
    "golang.Go"
    "ms-vscode.cpptools"
    "ms-python.python"
    "ms-azuretools.vscode-docker"
    "eamodio.gitlens"
    "redhat.vscode-yaml"
    "zxh404.vscode-proto3"
    "ms-vscode.cmake-tools"
  )

  echo "[*] Устанавливаю расширения VS Code..."
  for ext in "${extensions[@]}"; do
    echo "  -> $ext"
    code --install-extension "$ext" --force
  done

  echo "[✓] Установка завершена!"
}

setup_terminal_transp() {
  # Получаем UUID текущего (по умолчанию) профиля
  PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")

  # Базовый путь к настройкам профиля
  PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/"

  # Включаем использование прозрачного фона
  gsettings set "$PROFILE_PATH" use-transparent-background true

  # Устанавливаем уровень прозрачности (0 — непрозрачно, 100 — полностью прозрачно)
  gsettings set "$PROFILE_PATH" background-transparency-percent 10
}

# -------------------------------
# Main
# -------------------------------
echo "🚀 Updating system..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl git nodejs npm build-essential ripgrep fd-find python3-dev python3-venv dconf-cli uuid-runtime
sudo snap install task --classic
wget https://github.com/Eugeny/tabby/releases/download/v1.0.225/tabby-1.0.225-linux-x64.deb
sudo apt install ./tabby-1.0.225-linux-x64.deb
rm -f ./tabby-1.0.225-linux-x64.deb

if [[ -n "$BIN_TOOLS" ]]; then
  install_bin_tools
fi

install_lazygit
install_go_fixed
install_latest_rust
install_zsh_and_zinit
install_dotfiles
install_go_tools
install_neovim_plugins
setup_gnome_term_theme
install_vs_code
setup_terminal_transp

echo "✅ Setup complete!"
exec zsh -l
