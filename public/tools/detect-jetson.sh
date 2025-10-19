#!/bin/bash
# detect-jetson.sh — Determine if the system is an NVIDIA Jetson board.
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
#   detect-jetson.sh [--quiet] [--no-color] [--help]
#
# DESCRIPTION
#   Exit with status 0 if the host appears to be an NVIDIA Jetson board,
#   otherwise exit with status 1. Diagnostic messages are written to standard error.
#
# LIST OF HEURISTICS
#   1. Architecture gate: all jetson boards are ARM/ARM64.
#   2. Firmware interface: if ACPI (and no Device Tree) on ARM -> not Jetson.
#   3. Device Tree "model" contains /nvidia.*jetson/i -> Jetson.
#   4. Device Tree "compatible" contains nvidia, jetson or Tegra IDs (124,132,186,194,210,234) -> Jetson.
#   5. Fallback: presence of /etc/nv_tegra_release (L4T/JetPack) -> Jetson.
#
# OPTIONS
#   --quiet     Suppress diagnostics (stderr). Exit status still indicates result.
#   --no-color  Disable colored diagnostics.
#   --help      Print this help and exit 0.
#
# FILES
#   /sys/firmware/devicetree/base   Live Device Tree (preferred).
#   /proc/device-tree               Alternate path (often a symlink to the above).
#   /sys/firmware/acpi              ACPI presence indicator.
#   /etc/nv_tegra_release           Legacy L4T/JetPack marker.
#
# EXIT STATUS
#   0  Jetson detected.
#   1  Not a Jetson.
#   >1 Unexpected error; a diagnostic is printed to stderr.
#
# EXAMPLES
#   if ./detect-jetson.sh; then
#     IS_JETSON=true
#   else
#     IS_JETSON=false
#   fi
#
# REPORTING BUGS
#   Open an issue under https://github.com/EOLab-HSRW/drones/issues and
#   please include a full log output of the script.
#
#
# IDEAS
#   Should we fetch the upstream Tegra IDs from https://www.kernel.org/doc/Documentation/devicetree/bindings/arm/tegra.yaml
#   and fallback to our list in case of timeout/offline ?

set -euo pipefail

QUIET=false
USE_COLOR=true

print_help() {
  sed -n '1,/^set -euo pipefail/p' "$0" | sed '$d'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --quiet)    QUIET=true; shift ;;
    --no-color) USE_COLOR=false; shift ;;
    --help)     print_help; exit 0 ;;
    --)         shift; break ;;
    -*)
      echo "detect-jetson.sh: unknown option: $1" >&2
      echo "Try 'detect-jetson.sh --help' for more information." >&2
      exit 2
      ;;
    *) break ;;
  esac
done

if $USE_COLOR; then
  RED='\033[0;31m';
  GREEN='\033[0;32m';
  YELLOW='\033[1;33m';
  BLUE='\033[0;34m';
  NC='\033[0m'
else
  RED='';
  GREEN='';
  YELLOW='';
  BLUE='';
  NC=''
fi

log_ok()   { $QUIET || echo -e "${GREEN}[+]${NC} $*" >&2; }
log_info() { $QUIET || echo -e "${BLUE}[*]${NC} $*"  >&2; }
log_warn() { $QUIET || echo -e "${YELLOW}[!]${NC} $*" >&2; }
log_fail() { $QUIET || echo -e "${RED}[x]${NC} $*"   >&2; }

current_command=""
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'log_fail "\"$last_command\" failed with exit code $? in $0"' ERR

read_dt_prop() {
  # Usage: read_dt_prop /path/to/property
  # Prints the property with NUL bytes removed; prints nothing if unreadable.
  local path="$1"
  if [[ -r "$path" ]]; then
    tr -d $'\0' < "$path" || true
  fi
}

log_info "Starting NVIDIA Jetson detection…"

# 1) Architecture gate
ARCH="$(uname -m)"
log_info "Detected architecture: ${ARCH}"
case "$ARCH" in
  aarch64|arm64|armv7l|armv7*|armv8*|armv6*)
    log_ok "ARM architecture detected — continuing."
    ;;
  *)
    log_warn "Non-ARM architecture. Jetson requires ARM."
    exit 1
    ;;
esac

# 2) Firmware interface: Device Tree vs ACPI
HAS_ACPI=false
HAS_DT=false
DT_BASE=""

if [[ -d /sys/firmware/acpi ]]; then
  HAS_ACPI=true
  log_info "ACPI present: /sys/firmware/acpi"
fi

if   [[ -d /sys/firmware/devicetree/base ]]; then
  HAS_DT=true
  DT_BASE="/sys/firmware/devicetree/base"
  log_info "Device Tree base: ${DT_BASE}"
elif [[ -d /proc/device-tree ]]; then
  HAS_DT=true
  DT_BASE="/proc/device-tree"
  log_info "Device Tree base (proc): ${DT_BASE}"
else
  log_warn "No Device Tree path detected."
fi

# Jetson typically uses Device Tree; ACPI-only on ARM is treated as non-Jetson.
if [[ "$HAS_ACPI" == true && "$HAS_DT" == false ]]; then
  log_warn "ARM + ACPI (no Device Tree) — treating as non-Jetson."
  exit 1
fi

# 3) Device Tree "model"
if [[ "$HAS_DT" == true && -r "$DT_BASE/model" ]]; then
  MODEL="$(read_dt_prop "$DT_BASE/model")"
  if echo "$MODEL" | grep -qiE 'nvidia.*jetson'; then
    log_ok "DT model indicates Jetson: $(echo "$MODEL" | tr -s ' ' | head -c 120)"
    exit 0
  else
    log_info "DT model present but not Jetson: $(echo "$MODEL" | tr -s ' ' | head -c 120)"
  fi
fi

# 4) Device Tree "compatible"
if [[ "$HAS_DT" == true && -r "$DT_BASE/compatible" ]]; then
  if read_dt_prop "$DT_BASE/compatible" | grep -Eqi 'nvidia,(jetson|tegra(124|132|186|194|210|234))'; then
    log_ok "DT compatible contains an NVIDIA Jetson/Tegra identifier."
    exit 0
  else
    log_info "DT compatible lacks the expected Jetson/Tegra identifiers."
  fi
fi

# 5) Fallback: /etc/nv_tegra_release
if [[ -f /etc/nv_tegra_release ]]; then
  log_ok "Found /etc/nv_tegra_release (L4T/JetPack marker)."
  exit 0
else
  log_info "No /etc/nv_tegra_release found."
fi

# Informational (non-decisive)
if command -v tegrastats >/dev/null 2>&1; then
  log_info "tegrastats present (informational; not used in detection process)."
fi

# Final verdict
log_warn "No Jetson indicators matched."
exit 1

