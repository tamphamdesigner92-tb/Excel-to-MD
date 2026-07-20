#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$APP_DIR/.venv"
APP_URL="${APP_URL:-http://127.0.0.1:5000}"

cd "$APP_DIR"

print_header() {
  printf '\n==========================================================\n'
  printf '      HE THONG XU LY EXCEL - TU DONG KHOI DONG\n'
  printf '==========================================================\n\n'
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ensure_homebrew() {
  if command_exists brew; then
    return 0
  fi

  printf '[!] Chua tim thay Homebrew. Dang cai dat Homebrew...\n'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

ensure_python() {
  if command_exists python3; then
    PYTHON_BIN="$(command -v python3)"
    return 0
  fi

  printf '[!] Chua tim thay Python 3. Dang cai dat Python bang Homebrew...\n'
  ensure_homebrew
  brew install python

  if ! command_exists python3; then
    printf '[x] Khong the tim thay python3 sau khi cai dat. Hay mo lai Terminal va chay lai script.\n' >&2
    exit 1
  fi

  PYTHON_BIN="$(command -v python3)"
}

ensure_requirements_file() {
  if [[ ! -f "$APP_DIR/requirements.txt" ]]; then
    printf '[x] Khong tim thay requirements.txt trong: %s\n' "$APP_DIR" >&2
    exit 1
  fi
}

ensure_virtualenv() {
  if [[ ! -d "$VENV_DIR" ]]; then
    printf '[1/4] Dang tao moi moi truong ao Python...\n'
    "$PYTHON_BIN" -m venv "$VENV_DIR"
  else
    printf '[1/4] Da co moi truong ao Python.\n'
  fi

  # shellcheck source=/dev/null
  source "$VENV_DIR/bin/activate"
}

install_dependencies() {
  printf '[2/4] Dang cap nhat pip va cai dat thu vien can thiet...\n'
  "$VENV_DIR/bin/python" -m ensurepip --upgrade >/dev/null 2>&1 || true
  "$VENV_DIR/bin/python" -m pip install --upgrade pip
  "$VENV_DIR/bin/python" -m pip install -r "$APP_DIR/requirements.txt"
}

open_browser_when_ready() {
  (
    for _ in {1..30}; do
      if curl -fsS "$APP_URL" >/dev/null 2>&1; then
        open "$APP_URL"
        exit 0
      fi
      sleep 1
    done

    open "$APP_URL"
  ) &
}

start_app() {
  printf '\n[3/4] Dang khoi dong Web Server...\n'
  printf 'Trinh duyet web se tu dong mo tai: %s\n\n' "$APP_URL"

  open_browser_when_ready

  printf '[4/4] Server dang chay. VUI LONG KHONG TAT CUA SO NAY TRONG LUC DUNG WEB.\n'
  printf 'Nhan Ctrl + C de dung server khi khong con su dung.\n'
  printf '%s\n' '----------------------------------------------------------'

  "$VENV_DIR/bin/python" "$APP_DIR/app.py"
}

print_header
ensure_requirements_file
ensure_python
ensure_virtualenv
install_dependencies
start_app
