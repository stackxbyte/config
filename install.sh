#!/usr/bin/env bash
#
# install.sh - one-shot deploy script for this vim config.
#
# Supported: Fedora (dnf), Ubuntu / Linux Mint / Debian (apt).
#
# What it does:
#   1. Installs base system packages (vim, git, curl, compilers, python3,
#      fzf, ripgrep, powerline fonts) via apt/dnf.
#   2. Ensures Vim >= 9.0.0438 (required by coc.nvim) - falls back to a
#      Vim 9 AppImage if the distro ships an older Vim.
#   3. Ensures Node.js >= 22.15.0 (required by coc.nvim) - installs the
#      latest LTS into ~/node if the system one is missing/too old.
#   4. Backs up and deploys .vimrc and .vim into $HOME.
#   5. Installs all plugins via vim-plug.
#
#   coc-clangd installs itself automatically on your first real `vim` launch
#   (it is listed in g:coc_global_extensions inside .vimrc).
#
# Usage:
#   ./install.sh          (run as a NORMAL user, sudo is used internally)
#   ./install.sh --skip-apt   # skip system packages, only deploy config
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIMRC_SRC="$SCRIPT_DIR/.vimrc"
VIMDIR_SRC="$SCRIPT_DIR/.vim"

SKIP_PKGS=0
for a in "$@"; do
  case "$a" in
    --skip-apt|--skip-pkgs) SKIP_PKGS=1 ;;
    *) echo "unknown option: $a"; exit 1 ;;
  esac
done

# ---------------------------------------------------------------- helpers --
info() { printf '\033[1;36m[..]\033[0m %s\n' "$*"; }
step() { printf '\033[1;33m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[OK]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;31m[!!]\033[0m %s\n' "$*" >&2; }

require_cmd() { command -v "$1" >/dev/null 2>&1 || { warn "missing command: $1"; exit 1; }; }

# version_ge <current> <minimum>  -> "true"/"false"
version_ge() {
  python3 - "$1" "$2" <<'PY'
import sys
def v(s):
    return tuple(int(x) for x in s.strip().split('.'))
print(v(sys.argv[1]) >= v(sys.argv[2]))
PY
}

# add_to_path <dir>  (persist in shell rc files, idempotent)
add_to_path() {
  local dir="$1" rc
  for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    [ -f "$rc" ] || continue
    grep -qF -- "$dir" "$rc" 2>/dev/null || printf '\nexport PATH="%s:$PATH"\n' "$dir" >>"$rc"
  done
}

# ------------------------------------------------------------- main checks --
[ -f "$VIMRC_SRC" ]      || { warn "missing $VIMRC_SRC"; exit 1; }
[ -d "$VIMDIR_SRC" ]     || { warn "missing $VIMDIR_SRC"; exit 1; }
require_cmd sudo
require_cmd curl
require_cmd python3
require_cmd tar

if [ "$(id -u)" -eq 0 ]; then
  warn "You are root: the config would deploy to /root."
  warn "Run this script as a NORMAL user (sudo is used internally)."
  exit 1
fi

# distro detection
detect_pkg() {
  [ -f /etc/os-release ] || { warn "cannot detect OS (/etc/os-release missing)"; exit 1; }
  . /etc/os-release >/dev/null 2>&1 || true
  case "$ID" in
    ubuntu|debian|linuxmint|pop|elementary|zorin|kali|raspbian) echo deb ;;
    fedora|rhel|centos|rocky|almalinux|redhat)                    echo rpm ;;
    *) warn "unsupported distro: $ID (add support in detect_pkg of this script)"; exit 1 ;;
  esac
}
PKG="$(detect_pkg)"

# -------------------------------------------------------- system packages --
install_pkgs() {
  step "Installing base system packages..."
  if [ "$PKG" = "deb" ]; then
    sudo apt-get update -y
    sudo apt-get install -y git curl gcc g++ make build-essential \
      python3 vim-gtk3 fzf
    if ! sudo apt-get install -y fonts-powerline >/dev/null 2>&1; then
      warn "fonts-powerline unavailable (optional, skipping)"
    fi
  else
    sudo dnf install -y git curl gcc gcc-c++ make python3 vim-enhanced fzf
    if ! sudo dnf install -y powerline-fonts >/dev/null 2>&1; then
      if ! sudo dnf install -y fontconfig >/dev/null 2>&1; then
        warn "powerline fonts unavailable (optional, skipping)"
      fi
    fi
  fi
}

# ripgrep (fzf :Rg needs it); falls back to a static binary on old repos
ensure_rg() {
  command -v rg >/dev/null 2>&1 && return 0
  step "Installing ripgrep..."
  if [ "$PKG" = "deb" ]; then
    sudo apt-get install -y ripgrep 2>/dev/null && return 0
  else
    sudo dnf install -y ripgrep 2>/dev/null && return 0
  fi
  warn "ripgrep not in package repos, downloading static binary..."
  local ver="14.1.1"
  local arch; case "$(uname -m)" in x86_64) arch=x86_64 ;; aarch64|arm64) arch=aarch64 ;; *) warn "no rg binary for arch $(uname -m)"; return 1 ;; esac
  local tmp; tmp="$(mktemp -d)"
  local url="https://github.com/BurntSushi/ripgrep/releases/download/${ver}/ripgrep-${ver}-${arch}-unknown-linux-musl.tar.gz"
  if curl -fsSL "$url" -o "$tmp/rg.tar.gz" \
     && tar -xzf "$tmp/rg.tar.gz" -C /usr/local/bin --strip-components=1 \
          --wildcards "ripgrep-${ver}-*/rg" 2>/dev/null; then
    ok "ripgrep installed to /usr/local/bin/rg"
  else
    warn "ripgrep install failed; :Rg in fzf.vim will need rg on PATH"
  fi
  rm -rf "$tmp"
}

# ---- Vim >= 9.0.0438 (coc.nvim hard requirement) ----
ensure_vim() {
  if command -v vim >/dev/null 2>&1; then
    local v
    v="$(vim --version | sed -n '1s/.*IMproved \([0-9.]*\).*/\1/p')"
    v="${v:-0.0}"
    if [ "$(version_ge "$v" "9.0.0438")" = "True" ] || [ "$(version_ge "$v" "9.0.0438")" = "true" ]; then
      ok "Vim $v detected"
      return 0
    fi
    warn "System Vim is $v (coc.nvim wants >= 9.0.0438), installing Vim 9 AppImage..."
  fi
  # make sure FUSE is available for AppImages on newer distros
  if [ "$PKG" = "deb" ]; then
    sudo apt-get install -y libfuse2 >/dev/null 2>&1 || \
      sudo apt-get install -y libfuse2t64 >/dev/null 2>&1 || true
  fi
  install_vim_appimage
}

install_vim_appimage() {
  mkdir -p "$HOME/.local/bin"
  local app="$HOME/.local/bin/vim.appimage"
  info "Fetching latest Vim 9 AppImage from vim/vim-appimage ..."
  local newname=""
  if [ ! -e "$app" ]; then
    newname="$(python3 - "$app" <<'PY'
import json, sys, urllib.request, os, stat
path = sys.argv[1]
url = "https://api.github.com/repos/vim/vim-appimage/releases/latest"
with urllib.request.urlopen(url, timeout=30) as r:
    data = json.load(r)
assets = [a for a in data.get("assets", []) if a["name"].endswith("-amd64.AppImage")]
if not assets:
    sys.exit(1)
a = assets[0]
print(a["name"])
urllib.request.urlretrieve(a["browser_download_url"], path)
os.chmod(path, os.stat(path).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
PY
)" || true
  fi
  if [ -z "$newname" ] && [ ! -x "$app" ]; then
    warn "Vim 9 AppImage download failed; installing system Vim again (coc may not work)"
    if [ "$PKG" = "deb" ]; then sudo apt-get install -y vim >/dev/null 2>&1 || true; fi
    return 1
  fi
  [ -z "$newname" ] && newname="(already present)"
  ok "Downloaded $newname"
  # try to run via FUSE, else extract manually
  if ! "$app" --version >/dev/null 2>&1; then
    info "FUSE unavailable, extracting AppImage ..."
    local tmp; tmp="$(mktemp -d)"
    if ( cd "$tmp" && "$app" --appimage-extract >/dev/null 2>&1 && cp -f squashfs-root/usr/bin/vim "$HOME/.local/bin/vim" && chmod +x "$HOME/.local/bin/vim" ); then
      rm -f "$app"; rm -rf "$tmp"
    else
      rm -rf "$tmp"
      warn "Vim 9 AppImage failed to run; install Vim 9 manually"
      return 1
    fi
  else
    ln -sf "$app" "$HOME/.local/bin/vim"
  fi
  if "$HOME/.local/bin/vim" --version >/dev/null 2>&1; then
    ok "Vim 9 installed to ~/.local/bin/vim"
  fi
}

# ---- Node.js >= 22.15.0 (coc.nvim hard requirement) ----
ensure_node() {
  if command -v node >/dev/null 2>&1; then
    local nv; nv="$(node --version | sed 's/^v//')"
    if [ "$(version_ge "$nv" "22.15.0")" = "True" ] || [ "$(version_ge "$nv" "22.15.0")" = "true" ]; then
      ok "Node.js $nv detected"
      return 0
    fi
    warn "Node.js $nv too old (coc.nvim wants >= 22.15.0), installing latest LTS..."
  fi
  step "Installing Node.js LTS into ~/node (coc.nvim's recommended installer)..."
  curl -fsSL https://install-node.vercel.app/lts | bash -s -- --yes --prefix="$HOME/node" \
    || { warn "Node.js install failed; coc.nvim will not work"; return 1; }
  export PATH="$HOME/node/bin:$PATH"
  add_to_path "$HOME/node/bin"
  ok "Node.js $(node --version) installed"
}

# ---------------------------------------------------------------- deploy ---
deploy_config() {
  step "Deploying .vimrc and .vim to $HOME ..."
  local ts; ts="$(date +%Y%m%d-%H%M%S)"
  if [ -e "$HOME/.vimrc" ]; then cp -a "$HOME/.vimrc" "$HOME/.vimrc.bak.$ts"; ok "backed up ~/.vimrc -> ~/.vimrc.bak.$ts"; fi
  if [ -e "$HOME/.vim" ];    then cp -a "$HOME/.vim"    "$HOME/.vim.bak.$ts";    ok "backed up ~/.vim -> ~/.vim.bak.$ts"; fi

  cp -f "$VIMRC_SRC" "$HOME/.vimrc"
  mkdir -p "$HOME/.vim"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --exclude=plugged --exclude=undo --exclude='.netrwhist' \
      "$VIMDIR_SRC/" "$HOME/.vim/"
  else
    ( cd "$VIMDIR_SRC" && tar --exclude=plugged --exclude=undo --exclude=.netrwhist -cf - . ) \
      | ( cd "$HOME/.vim" && tar -xf - )
  fi
  mkdir -p "$HOME/.vim/undo"
  ok "config deployed"
}

# ------------------------------------------------------------- wind-up ----
install_plugins() {
  step "Installing plugins with vim-plug (first run takes a while)..."
  if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    info "bootstrapping vim-plug ..."
    curl -fsSL https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
      -o "$HOME/.vim/autoload/plug.vim"
  fi
  local log; log="$(mktemp)"
  vim -n -es -u "$HOME/.vimrc" -i NONE -c 'PlugInstall --sync' -c 'qa!' \
    </dev/null >"$log" 2>&1 || true

  local miss=""
  local p
  for p in nerdtree coc.nvim fzf fzf.vim vim-commentary vim-surround \
           vim-fugitive vim-floaterm auto-pairs vim-airline \
           vim-airline-themes gruvbox; do
    if [ ! -d "$HOME/.vim/plugged/$p" ]; then miss="$miss $p"; fi
  done
  if [ -z "$miss" ]; then
    ok "all plugins installed"
  else
    warn "plugins missing:$miss"
    sed -n '1,40p' "$log"
    warn "rerun with: vim +PlugInstall +qa"
  fi
  rm -f "$log"
}

# ------------------------------------------------------------------ main ---
if [ "$SKIP_PKGS" -eq 1 ]; then
  info "Skipping system package installation (--skip-apt)"
else
  install_pkgs
fi
ensure_rg
ensure_vim
ensure_node
deploy_config
install_plugins

cat <<EOF

\033[1;32mAll done!\033[0m  Your vim config is deployed and plugins are installed.

Before you start: on your FIRST vim launch, coc.nvim automatically downloads
the coc-clangd extension (this uses g:coc_global_extensions). Wait for the
progress message, then quit and reopen vim.

Key features:
  ,                 leader key
  <F5>              compile & run    (c/cpp/python)
  <F6>              NERDTree toggle
  <F7>/<F8>         float terminal toggle/next
  <C-p>             fzf files
  <C-t>             new tab
  <C-h/j/k/l>       split navigation
  jjkk              exit insert mode

If $HOME/.local/bin or $HOME/node/bin were added to your shell rc,
either open a new shell or run:  source ~/.bashrc
EOF
exit 0