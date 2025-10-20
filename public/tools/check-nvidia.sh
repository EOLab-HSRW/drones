#!/bin/bash
# check-nvidia.sh — Detect NVIDIA GPU, driver & CUDA toolkit; optionally detect Jetson and install missing drivers or toolkit.
#
# This file of part of the EOLab Drones Ecosystem (drones.eolab.de) with
# the home repository in: https://github.com/EOLab-HSRW/drones
#
# Copyright (C) 2025  Harley Lara
#
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# SYNOPSIS
#   check-nvidia.sh [--quiet] [--no-color] [--help]
#                        [--auto-install-driver] [--auto-install-cuda] [--assume-yes]
#                        [--cuda-version=MAJOR.MINOR] [--no-env] [--rc-file=PATH]
#                        [gpu|driver|toolkit|all]
#
# DESCRIPTION
#   Exit with status 0 if the requested check passes, otherwise exit with 1.
#   Subcommands:
#     gpu     : Passes if an NVIDIA GPU is detected (via lspci or nvidia-smi).
#     driver  : Passes if the NVIDIA driver is healthy (nvidia-smi succeeds).
#     toolkit : Passes if the CUDA toolkit is available (nvcc + headers).
#     all     : All of the above must pass (default).
#
#   If checks fail, this script can install the missing pieces:
#     - If the driver check fails:
#         1) Fetch (temporarily) the Jetson detector:
#            https://raw.githubusercontent.com/EOLab-HSRW/drones/refs/heads/main/public/tools/detect-jetson.sh
#            to determine whether the system is a Jetson board.
#         2) Depending on the result, OFFER to install drivers:
#              - Jetson (Ubuntu for Jetson) using jetpack:     sudo apt-get install nvidia-jetpack
#              - Non-Jetson Ubuntu (PC/Laptop):  sudo ubuntu-drivers autoinstall
#            Use --auto-install-driver to skip the prompt and proceed automatically.
#            Use --assume-yes to pass -y to apt operations.
#     - If the CUDA toolkit check fails (Ubuntu/Debian), OFFER to install from NVIDIA's APT repo
#       (optionally pin a version with --cuda-version). Use --auto-install-cuda to skip the prompt.
#
#   Notes:
#     - On WSL, the Windows host must provide the driver; this script will not install a Linux driver,
#       but it can install the CUDA toolkit inside WSL.
#
# OPTIONS
#   --quiet                Suppress diagnostics (stderr). Exit status still indicates result.
#   --no-color             Disable colored diagnostics.
#   --help                 Print this help and exit 0.
#   --auto-install-driver  If driver is missing/broken, install without prompting (when supported).
#   --auto-install-cuda    If toolkit is missing, install without prompting (when supported).
#   --assume-yes           Non-interactive apt installs (-y).
#   --cuda-version=V       Desired CUDA toolkit version (e.g., 12.4). Falls back to generic if unavailable.
#   --no-env               Do not append CUDA PATH/LD_LIBRARY_PATH to shell rc file.
#   --rc-file=PATH         Shell rc file for env exports (default: ~/.bashrc).
#
# EXIT STATUS
#   0  Check(s) passed (or post-install best-effort succeeded).
#   1  Check(s) failed or install skipped/failed.
#   2  Usage error / unknown option.
#   >2 Unexpected error; a diagnostic is printed to stderr.
#
# EXAMPLES
#   # Simple check with summary
#   ./check-nvidia.sh all
#
#   # Auto-fix drivers and toolkit if missing (Ubuntu/Jetson)
#   ./check-nvidia.sh --auto-install-driver --auto-install-cuda --assume-yes --cuda-version=12.4
#
#   # Source to reuse functions
#   . ./check-nvidia.sh
#   if check_nvidia_gpu && check_nvidia_driver && check_toolkit_nvcc && check_toolkit_headers; then echo "OK"; fi
#
# REPORTING BUGS
#   Open an issue under https://github.com/EOLab-HSRW/drones/issues and
#   please include a full log output of the script.

set -euo pipefail

# --------------------------- CLI / Help ---------------------------

QUIET=false
USE_COLOR=true
AUTO_INSTALL_DRIVER=false
AUTO_INSTALL_CUDA=false
ASSUME_YES=false
CUDA_VERSION=""
WRITE_ENV=true
RC_FILE="${HOME}/.bashrc"

print_help() {
  sed -n '1,/^set -euo pipefail/p' "$0" | sed '$d'
}

# Parse global options; stop at first non-option (the subcommand)
while [[ $# -gt 0 ]]; do
  case "$1" in
    --quiet)                QUIET=true; shift ;;
    --no-color)             USE_COLOR=false; shift ;;
    --help)                 print_help; exit 0 ;;
    --auto-install-driver)  AUTO_INSTALL_DRIVER=true; shift ;;
    --auto-install-cuda)    AUTO_INSTALL_CUDA=true; shift ;;
    --assume-yes)           ASSUME_YES=true; shift ;;
    --cuda-version=*)       CUDA_VERSION="${1#*=}"; shift ;;
    --no-env)               WRITE_ENV=false; shift ;;
    --rc-file=*)            RC_FILE="${1#*=}"; shift ;;
    --)                     shift; break ;;
    -*)
      echo "check-nvidia.sh: unknown option: $1" >&2
      echo "Try 'check-nvidia.sh --help' for more information." >&2
      exit 2
      ;;
    *) break ;;
  esac
done

# --------------------------- Colors & Logging ---------------------------

if $USE_COLOR; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
fi

log_ok()   { $QUIET || echo -e "${GREEN}[+]${NC} $*" >&2; }
log_info() { $QUIET || echo -e "${BLUE}[*]${NC} $*"  >&2; }
log_warn() { $QUIET || echo -e "${YELLOW}[!]${NC} $*" >&2; }
log_fail() { $QUIET || echo -e "${RED}[x]${NC} $*"   >&2; }

ask_yes_no_driver() {
  # Returns 0 ("yes") if AUTO_INSTALL_DRIVER or user answered y/Y
  $AUTO_INSTALL_DRIVER && return 0
  read -r -p "$1 [y/N]: " ans </dev/tty || { echo; return 1; }
  [[ "${ans:-}" =~ ^[Yy]$ ]]
}

ask_yes_no_cuda() {
  # Returns 0 ("yes") if AUTO_INSTALL_CUDA or user answered y/Y
  $AUTO_INSTALL_CUDA && return 0
  read -r -p "$1 [y/N]: " ans </dev/tty || { echo; return 1; }
  [[ "${ans:-}" =~ ^[Yy]$ ]]
}

current_command=""
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'log_fail "\"$last_command\" failed with exit code $? in $0"' ERR

# --------------------------- Helpers ---------------------------

have_cmd() { command -v "$1" >/dev/null 2>&1; }

# GPU presence
check_nvidia_gpu() {
  if have_cmd lspci && lspci | grep -qi 'NVIDIA'; then return 0; fi
  if have_cmd nvidia-smi && nvidia-smi -L >/dev/null 2>&1; then return 0; fi
  return 1
}

# Driver health (nvidia-smi runs)
check_nvidia_driver() {
  if have_cmd nvidia-smi && nvidia-smi >/dev/null 2>&1; then return 0; fi
  return 1
}

# Toolkit present (nvcc + headers)
check_toolkit_nvcc()     { have_cmd nvcc; }
check_toolkit_headers() {
  [[ -f /usr/local/cuda/include/cuda_runtime.h ]] && return 0
  [[ -f /usr/lib/cuda/include/cuda_runtime.h ]] && return 0
  [[ -f /usr/include/cuda_runtime.h ]] && return 0
  return 1
}

is_wsl() { [[ -f /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; }

# Info helpers
gather_gpu_list() {
  if have_cmd nvidia-smi && nvidia-smi -L >/dev/null 2>&1; then
    nvidia-smi -L 2>/dev/null || true
    return
  fi
  if have_cmd lspci; then
    lspci -nn | grep -Ei 'VGA|3D' | grep -i nvidia | sed 's/^[^:]*: //'
  fi
}
driver_version_from_nvsmi() {
  have_cmd nvidia-smi || return 0
  nvidia-smi 2>/dev/null | sed -n 's/.*Driver Version:[[:space:]]*\([0-9.]\+\).*/\1/p' | head -n1 || true
}
cuda_from_driver() {
  have_cmd nvidia-smi || return 0
  nvidia-smi 2>/dev/null | sed -n 's/.*CUDA Version:[[:space:]]*\([0-9.]\+\).*/\1/p' | head -n1 || true
}
nvcc_version() {
  have_cmd nvcc || return 0
  nvcc --version 2>/dev/null | sed -n 's/.*release \([0-9.]\+\).*/\1/p' | head -n1 || true
}
print_modules_info() {
  if have_cmd lsmod; then
    if lsmod | grep -qw nvidia; then echo "nvidia (loaded)"; fi
    if lsmod | grep -qw nvidia_drm; then echo "nvidia_drm (loaded)"; fi
    if lsmod | grep -qw nouveau; then echo "nouveau (loaded)"; fi
  fi
}
secure_boot_state() {
  if have_cmd mokutil; then
    mokutil --sb-state 2>/dev/null | tr -s ' ' || true
  fi
}
env_descriptor() {
  if is_wsl; then echo "WSL (Windows Subsystem for Linux) detected"; fi
}

# --------------------------- Jetson detection (runtime fetch) ---------------------------

detect_jetson_runtime() {
  # Returns 0 if Jetson is detected by the upstream script, 1 otherwise.
  local url="https://raw.githubusercontent.com/EOLab-HSRW/drones/refs/heads/main/public/tools/detect-jetson.sh"
  local tmp
  tmp="$(mktemp -t detect-jetson.XXXXXX.sh)"
  trap 'rm -f "$tmp" || true' RETURN

  log_info "Fetching Jetson detector from upstream (https://drones.eolab.de/tools/detect-jetson.sh)"
  if have_cmd curl; then
    if ! curl -fsSL "$url" -o "$tmp"; then
      log_warn "curl failed to download Jetson detector."
      return 1
    fi
  elif have_cmd wget; then
    if ! wget -qO "$tmp" "$url"; then
      log_warn "wget failed to download Jetson detector."
      return 1
    fi
  else
    log_warn "Neither curl nor wget found; cannot fetch Jetson detector."
    return 1
  fi

  chmod +x "$tmp"
  if "$tmp" --quiet; then
    log_ok "Upstream detector reports: Jetson = YES"
    return 0
  else
    log_info "Upstream detector reports: Jetson = NO"
    return 1
  fi
}

# --------------------------- Installers ---------------------------

install_drivers_ubuntu_pc() {
  local apt_y=()
  $ASSUME_YES && apt_y+=("-y")
  log_info "Installing Ubuntu proprietary NVIDIA driver (PC)…"
  sudo apt-get update "${apt_y[@]}"
  sudo apt-get install "${apt_y[@]}" ubuntu-drivers-common
  sudo ubuntu-drivers autoinstall
  log_ok "Driver installation invoked (reboot usually required)."
}

install_drivers_jetson() {
  local apt_y=()
  $ASSUME_YES && apt_y+=("-y")
  log_info "Installing NVIDIA Jetson drivers via 'nvidia-jetpack'…"
  sudo apt-get update "${apt_y[@]}"
  sudo apt-get install "${apt_y[@]}" nvidia-jetpack
  log_ok "Jetson driver/toolchain installation invoked (reboot usually required)."
}

install_cuda_toolkit_deb() {
  # Ubuntu/Debian toolkit install from NVIDIA repo
  local version="${1:-}"
  local apt_y=()
  $ASSUME_YES && apt_y+=("-y")

  if [[ -r /etc/os-release ]]; then . /etc/os-release; fi
  case "${ID:-}" in
    ubuntu) OS_TOKEN="ubuntu${VERSION_ID//./}" ;;
    debian) OS_TOKEN="debian${VERSION_ID%%.*}" ;;
    *) log_warn "Unsupported distro for automatic CUDA install. Please install manually."; return 1 ;;
  esac

  local base="https://developer.download.nvidia.com/compute/cuda/repos/${OS_TOKEN}/x86_64"
  local keydeb="/tmp/cuda-keyring.deb"

  log_info "Adding NVIDIA CUDA APT repo (${base})…"
  if ! curl -fsSL "${base}/cuda-keyring_1.1-1_all.deb" -o "$keydeb" 2>/dev/null; then
    if ! wget -qO "$keydeb" "${base}/cuda-keyring_1.0-1_all.deb"; then
      log_warn "Failed to download cuda-keyring package."
      return 1
    fi
  fi
  sudo dpkg -i "$keydeb"
  sudo apt-get update "${apt_y[@]}"

  local pkg="cuda-toolkit"
  if [[ -n "$version" ]]; then
    local maj="${version%%.*}"
    local min="${version#*.}"
    pkg="cuda-toolkit-${maj}-${min}"
  fi

  log_info "Installing CUDA toolkit package: ${pkg}"
  if ! sudo apt-get install "${apt_y[@]}" "$pkg"; then
    if [[ "$pkg" != "cuda-toolkit" ]]; then
      log_warn "Specific version not available; falling back to 'cuda-toolkit'."
      sudo apt-get install "${apt_y[@]}" cuda-toolkit || return 1
    else
      return 1
    fi
  fi

  if $WRITE_ENV; then
    local MARK="# >>> CUDA toolkit environment (added by check-nvidia.sh) >>>"
    if ! grep -Fq "$MARK" "$RC_FILE" 2>/dev/null; then
      {
        echo "$MARK"
        echo 'if [ -d /usr/local/cuda ]; then'
        echo '  export CUDA_HOME=/usr/local/cuda'
        echo '  export PATH=$CUDA_HOME/bin:$PATH'
        echo '  export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$CUDA_HOME/lib64'
        echo 'fi'
        echo "# <<< CUDA toolkit environment <<<"
      } >> "$RC_FILE"
      log_ok "Appended CUDA env to ${RC_FILE}. Run: source '${RC_FILE}'"
    else
      log_info "CUDA env block already present in ${RC_FILE}; skipping."
    fi
  fi

  return 0
}

# --------------------------- Summary ---------------------------

print_summary() {
  local mode="$1" gpu_rc="$2" drv_rc="$3" tk_rc="$4"
  $QUIET && return 0

  local dver cdrv nvv
  dver="$(driver_version_from_nvsmi)"
  cdrv="$(cuda_from_driver)"
  nvv="$(nvcc_version)"

  echo -e "${BLUE}================== NVIDIA / CUDA SUMMARY ==================${NC}" >&2
  echo -e " Mode             : ${mode}" >&2
  echo -e " GPU check        : $([[ $gpu_rc -eq 0 ]] && echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}")" >&2
  echo -e " Driver check     : $([[ $drv_rc -eq 0 ]] && echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}")" >&2
  echo -e " Toolkit check    : $([[ $tk_rc  -eq 0 ]] && echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}")" >&2
  echo -e " Driver version   : ${dver:-n/a}" >&2
  echo -e " CUDA (driver max): ${cdrv:-n/a}" >&2
  echo -e " nvcc version     : ${nvv:-n/a}" >&2

  local env_note
  env_note="$(env_descriptor)"
  [[ -n "$env_note" ]] && echo -e " Environment      : ${env_note}" >&2

  echo -e " GPUs detected    :" >&2
  local gpus
  gpus="$(gather_gpu_list || true)"
  if [[ -n "${gpus:-}" ]]; then
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      echo -e "   - ${line}" >&2
    done <<< "$gpus"
  else
    echo -e "   - none" >&2
  fi

  echo -e " Kernel modules   :" >&2
  local mods
  mods="$(print_modules_info || true)"
  if [[ -n "${mods:-}" ]]; then
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      echo -e "   - ${line}" >&2
    done <<< "$mods"
  else
    echo -e "   - (no info / lsmod unavailable)" >&2
  fi

  local sb
  sb="$(secure_boot_state || true)"
  [[ -n "$sb" ]] && echo -e " Secure Boot      : ${sb}" >&2

  echo -e "${BLUE}===========================================================${NC}" >&2
}

usage_short() {
  cat <<EOF
Usage: check-nvidia.sh [--quiet] [--no-color] [--help]
                            [--auto-install-driver] [--auto-install-cuda] [--assume-yes]
                            [--cuda-version=MAJOR.MINOR] [--no-env] [--rc-file=PATH]
                            [gpu|driver|toolkit|all]
EOF
}

# --------------------------- Main (skip if sourced) ---------------------------

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  return 0
fi

mode="${1:-all}"

log_info "Starting NVIDIA / CUDA checks (mode: ${mode})…"

# Initial checks
gpu_rc=1
drv_rc=1
tk_rc=1

if check_nvidia_gpu; then
  log_ok "NVIDIA GPU detected."
  gpu_rc=0
else
  log_warn "No NVIDIA GPU detected."
  gpu_rc=1
fi

if check_nvidia_driver; then
  log_ok "NVIDIA driver is healthy (nvidia-smi succeeded)."
  drv_rc=0
else
  log_warn "NVIDIA driver not healthy or not installed."
  drv_rc=1
fi

if check_toolkit_nvcc && check_toolkit_headers; then
  log_ok "CUDA toolkit present (nvcc + headers)."
  tk_rc=0
else
  log_warn "CUDA toolkit not fully present."
  tk_rc=1
fi

# If GPU is missing, there's nothing useful to install (skip installs).
if [[ $gpu_rc -ne 0 ]]; then
  log_warn "Skipping driver/toolkit installation because no NVIDIA GPU was detected."
  print_summary "$mode" "$gpu_rc" "$drv_rc" "$tk_rc"
  case "$mode" in
    gpu)     exit "$gpu_rc" ;;
    driver)  exit 1 ;;
    toolkit) exit 1 ;;
    all)     exit 1 ;;
    *)       usage_short; echo "Unknown mode: ${mode}" >&2; exit 2 ;;
  esac
fi

# Try to install the driver if missing
if [[ $drv_rc -ne 0 ]]; then
  if is_wsl; then
    log_warn "WSL detected — install the NVIDIA driver on the Windows host, then re-check."
  else
    IS_JETSON=false
    if detect_jetson_runtime; then IS_JETSON=true; fi

    if ask_yes_no_driver "Install NVIDIA drivers for $([[ $IS_JETSON == true ]] && echo 'Jetson' || echo 'Ubuntu PC') now?"; then
      if [[ -r /etc/os-release ]]; then . /etc/os-release; fi
      if [[ "${ID:-}" != "ubuntu" ]]; then
        log_warn "Automatic driver installation currently supported only on Ubuntu. Please install manually."
      else
        if [[ $IS_JETSON == true ]]; then
          install_drivers_jetson || log_warn "Jetson driver installation encountered issues."
        else
          install_drivers_ubuntu_pc || log_warn "Ubuntu PC driver installation encountered issues."
        fi
        # Re-check (may still require reboot / Secure Boot enrollment)
        if check_nvidia_driver; then
          log_ok "Driver appears healthy after installation."
          drv_rc=0
        else
          log_warn "Driver still not healthy. A reboot or Secure Boot MOK enrollment may be required."
        fi
      fi
    else
      log_info "Driver installation skipped by user."
    fi
  fi
fi

# If we just installed Jetson drivers via nvidia-jetpack, toolkit may now be present.
if [[ $tk_rc -ne 0 ]]; then
  if check_toolkit_nvcc && check_toolkit_headers; then
    tk_rc=0
  else
    # Offer toolkit install (Ubuntu/Debian); allowed also in WSL
    if ask_yes_no_cuda "Install CUDA toolkit$([[ -n "$CUDA_VERSION" ]] && echo " ($CUDA_VERSION)") now?"; then
      if [[ -r /etc/os-release ]]; then . /etc/os-release; fi
      case "${ID:-}" in
        ubuntu|debian)
          if install_cuda_toolkit_deb "${CUDA_VERSION}"; then
            if check_toolkit_nvcc && check_toolkit_headers; then
              log_ok "CUDA toolkit is now present."
              tk_rc=0
            else
              log_warn "CUDA toolkit still not detected after installation."
            fi
          else
            log_warn "CUDA toolkit installation failed."
          fi
          ;;
        *)
          log_warn "Automatic CUDA installation is only implemented for Ubuntu/Debian. Please install manually."
          ;;
      esac
    else
      log_info "CUDA toolkit installation skipped by user."
    fi
  fi
fi

# Final summary & exit
print_summary "$mode" "$gpu_rc" "$drv_rc" "$tk_rc"

case "$mode" in
  gpu)     exit "$gpu_rc" ;;
  driver)  exit "$drv_rc" ;;
  toolkit) exit "$tk_rc" ;;
  all)
    if [[ $gpu_rc -eq 0 && $drv_rc -eq 0 && $tk_rc -eq 0 ]]; then
      exit 0
    else
      exit 1
    fi
    ;;
  *)
    usage_short
    echo "Unknown mode: ${mode}" >&2
    exit 2
    ;;
esac

