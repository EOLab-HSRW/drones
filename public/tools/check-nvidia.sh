#!/bin/bash
# check-nvidia — Detect NVIDIA GPU presence and driver health; optionally detect Jetson and install drivers.
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
#   check-nvidia [--quiet] [--no-color] [--help]
#                [--auto-install-driver] [--assume-yes]
#                [gpu|driver|all]
#
# DESCRIPTION
#   Exit with status 0 if the requested check passes, otherwise exit with 1.
#   Subcommands:
#     gpu     : Passes if an NVIDIA GPU is detected (via lspci or nvidia-smi).
#     driver  : Passes if the NVIDIA driver is healthy (nvidia-smi succeeds).
#     all     : Both gpu and driver checks must pass (default).
#
#   If the driver check fails, this script will:
#     1) Fetch (temporarily) the Jetson detector:
#        https://raw.githubusercontent.com/EOLab-HSRW/drones/refs/heads/main/public/tools/detect-jetson.sh
#        and run it to determine whether the system is a Jetson board.
#     2) Depending on the result, OFFER to install drivers:
#          - Jetson    : via 'sudo apt-get install nvidia-jetpack' (Ubuntu for Jetson)
#          - Non-Jetson Ubuntu : via 'ubuntu-drivers autoinstall'
#        Use --auto-install-driver to skip the prompt and proceed automatically.
#        Use --assume-yes to pass -y to apt operations.
#
# OPTIONS
#   --quiet               Suppress diagnostics (stderr). Exit status still indicates result.
#   --no-color            Disable colored diagnostics.
#   --help                Print this help and exit 0.
#   --auto-install-driver If driver is missing/broken, attempt the appropriate install without prompting.
#   --assume-yes          Non-interactive apt installs (-y).
#
# EXIT STATUS
#   0  Check passed (or post-install best-effort).
#   1  Check failed (or install not performed/failed).
#   >1 Unexpected error; a diagnostic is printed to stderr.
#
# EXAMPLES
#   # Simple check with summary
#   ./check-nvidia all
#
#   # Auto-fix drivers if missing (Ubuntu/Jetson)
#   ./check-nvidia --auto-install-driver --assume-yes all
#
#   # Source to reuse functions
#   . ./check-nvidia
#   if check_nvidia_gpu && check_nvidia_driver; then echo "OK"; fi
#
# REPORTING BUGS
#   Open an issue under https://github.com/EOLab-HSRW/drones/issues and
#   please include a full log output of the script.

set -euo pipefail

# --------------------------- CLI / Help ---------------------------

QUIET=false
USE_COLOR=true
AUTO_INSTALL_DRIVER=false
ASSUME_YES=false

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
    --assume-yes)           ASSUME_YES=true; shift ;;
    --)                     shift; break ;;
    -*)
      echo "check-nvidia: unknown option: $1" >&2
      echo "Try 'check-nvidia --help' for more information." >&2
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

ask_yes_no() {
  # ask_yes_no "Question?" -> returns 0 if yes, 1 if no
  local q="$1"
  if $AUTO_INSTALL_DRIVER; then
    return 0
  fi
  read -r -p "$q [y/N]: " ans </dev/tty || { echo; return 1; }
  [[ "${ans:-}" =~ ^[Yy]$ ]]
}

current_command=""
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'log_fail "\"$last_command\" failed with exit code $? in $0"' ERR

# --------------------------- Helpers ---------------------------

have_cmd() { command -v "$1" >/dev/null 2>&1; }

# Return 0 if an NVIDIA GPU is detected (by lspci or nvidia-smi)
check_nvidia_gpu() {
  if have_cmd lspci && lspci | grep -qi 'NVIDIA'; then
    return 0
  fi
  if have_cmd nvidia-smi && nvidia-smi -L >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

# Return 0 iff nvidia-smi runs successfully (driver loaded & healthy)
check_nvidia_driver() {
  if have_cmd nvidia-smi && nvidia-smi >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

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
  if [[ -f /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; then
    echo "WSL (Windows Subsystem for Linux) detected"
  fi
}

# --------------------------- Jetson detection (runtime fetch) ---------------------------

detect_jetson_runtime() {
  # Returns 0 if Jetson is detected by the upstream script, 1 otherwise.
  # If download/exec fails, returns 1 and logs a warning.
  local url="https://raw.githubusercontent.com/EOLab-HSRW/drones/refs/heads/main/public/tools/detect-jetson.sh"
  local tmp
  tmp="$(mktemp -t detect-jetson.XXXXXX.sh)"
  trap 'rm -f "$tmp" || true' RETURN

  log_info "Fetching Jetson detector from upstream…"
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

# --------------------------- Driver installation paths ---------------------------

install_drivers_ubuntu_pc() {
  # Non-Jetson Ubuntu path: ubuntu-drivers autoinstall
  local apt_y=()
  $ASSUME_YES && apt_y+=("-y")
  log_info "Installing Ubuntu proprietary NVIDIA driver (PC)…"
  sudo apt-get update "${apt_y[@]}"
  sudo apt-get install "${apt_y[@]}" ubuntu-drivers-common
  sudo ubuntu-drivers autoinstall
  log_ok "Driver installation invoked (reboot usually required)."
}

install_drivers_jetson() {
  # Jetson path: nvidia-jetpack meta (on Jetson Ubuntu). Requires NVIDIA repos preinstalled on Jetson images.
  local apt_y=()
  $ASSUME_YES && apt_y+=("-y")
  log_info "Installing NVIDIA Jetson drivers via 'nvidia-jetpack'…"
  sudo apt-get update "${apt_y[@]}"
  sudo apt-get install "${apt_y[@]}" nvidia-jetpack
  log_ok "Jetson driver/toolchain installation invoked (reboot usually required)."
}

# --------------------------- Summary ---------------------------

print_summary() {
  local mode="$1" gpu_pass="$2" drv_pass="$3"
  $QUIET && return 0

  local drv_ver cuda_drv
  drv_ver="$(driver_version_from_nvsmi)"
  cuda_drv="$(cuda_from_driver)"

  echo -e "${BLUE}==================== NVIDIA SUMMARY ====================${NC}" >&2
  echo -e " Mode          : ${mode}" >&2
  echo -e " GPU check     : $([[ $gpu_pass == 0 ]] && echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}")" >&2
  echo -e " Driver check  : $([[ $drv_pass == 0 ]] && echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}")" >&2
  echo -e " Driver ver    : ${drv_ver:-n/a}" >&2
  echo -e " CUDA (driver) : ${cuda_drv:-n/a}" >&2

  local env_note
  env_note="$(env_descriptor)"
  [[ -n "$env_note" ]] && echo -e " Environment   : ${env_note}" >&2

  echo -e " GPUs detected :" >&2
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

  echo -e " Kernel mods   :" >&2
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
  [[ -n "$sb" ]] && echo -e " Secure Boot   : ${sb}" >&2

  echo -e "${BLUE}========================================================${NC}" >&2
}

usage_short() {
  cat <<EOF
Usage: check-nvidia [--quiet] [--no-color] [--help] [--auto-install-driver] [--assume-yes] [gpu|driver|all]
EOF
}

# --------------------------- Main (skip if sourced) ---------------------------

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  return 0
fi

mode="${1:-all}"

log_info "Starting NVIDIA checks (mode: ${mode})…"

gpu_rc=1
drv_rc=1

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
  log_warn "NVIDIA driver not healthy or not installed (nvidia-smi failed)."
  drv_rc=1

  # 1) Detect Jetson (runtime fetch) to choose install path
  IS_JETSON=false
  if detect_jetson_runtime; then
    IS_JETSON=true
  fi

  # 2) Ask (or auto) to install appropriate drivers
  if $AUTO_INSTALL_DRIVER || ask_yes_no "Install NVIDIA drivers for $([[ $IS_JETSON == true ]] && echo 'Jetson' || echo 'Ubuntu PC') now?"; then
    if [[ -r /etc/os-release ]]; then . /etc/os-release; fi
    if [[ "${ID:-}" != "ubuntu" ]]; then
      log_warn "Automatic driver installation currently supported only on Ubuntu."
      log_warn "Please install manually for your distribution."
      # Keep drv_rc = 1; continue to summary
    else
      if [[ $IS_JETSON == true ]]; then
        install_drivers_jetson || log_warn "Jetson driver installation encountered issues."
      else
        install_drivers_ubuntu_pc || log_warn "Ubuntu PC driver installation encountered issues."
      fi

      # Re-check (may still fail until reboot / Secure Boot enrollment)
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

# Summary
print_summary "$mode" "$gpu_rc" "$drv_rc"

# Exit according to requested mode
case "$mode" in
  gpu)    exit "$gpu_rc" ;;
  driver) exit "$drv_rc" ;;
  all)
    if [[ $gpu_rc -eq 0 && $drv_rc -eq 0 ]]; then
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

