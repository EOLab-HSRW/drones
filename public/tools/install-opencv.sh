#!/bin/bash
# install-opencv.sh — Remove old OpenCV, detect Jetson & NVIDIA, then build OpenCV from source (CUDA if available, else CPU).
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
#   install-opencv.sh [--quiet] [--no-color] [--help]
#                     [--assume-yes] [--opencv-version=MAJOR.MINOR.PATCH]
#                     [--contrib] [--no-contrib]
#                     [--prefix=/usr/local] [--build-dir=/tmp/opencv-build] [--jobs=N]
#                     [--swap-size-gb=N] [--persist-swap]
#
# DESCRIPTION
#   This script removes previous OpenCV installations, detects whether the host is a Jetson board,
#   adds swap on Jetson (to aid compilation), checks for NVIDIA GPU/driver/CUDA toolkit using the
#   upstream checker, and compiles OpenCV from source. If NVIDIA + driver + CUDA toolkit are present,
#   it builds with CUDA support; otherwise it falls back to a CPU-only build.
#
#   At runtime, it downloads and executes:
#     • Jetson detector:
#         https://raw.githubusercontent.com/EOLab-HSRW/drones/refs/heads/main/public/tools/detect-jetson.sh
#     • NVIDIA checker ("all" mode verifies GPU, driver, and CUDA toolkit):
#         https://raw.githubusercontent.com/EOLab-HSRW/drones/refs/heads/main/public/tools/check-nvidia.sh
#
#   This script integrates Jetson-specific enhancements:
#     • Sets CUDA arch flags for Jetson Orin (8.7/sm_87) and Jetson Nano (5.3/sm_53)
#     • On Jetson Nano with GCC ≥ 9, offers to switch temporarily to GCC 8 via update-alternatives
#     • Limits jobs (-j) on Jetson based on available swap (≤ 5.5 GiB → -j1; else -j4)
#     • On Jetson, ensures /usr/local/cuda/lib64 is in the dynamic linker path
#     • Adds distro-specific multimedia dependencies (libswresample vs libavresample)
#
# OPTIONS
#   --quiet                Suppress diagnostics (stderr). Exit status still indicates result.
#   --no-color             Disable colored diagnostics.
#   --help                 Print this help and exit 0.
#   --assume-yes           Pass -y to apt operations and skip confirmations.
#   --opencv-version=V     OpenCV version tag to build (default: 4.11.0).
#   --contrib              Build with opencv_contrib modules (default).
#   --no-contrib           Do not build opencv_contrib modules.
#   --prefix=PATH          CMake install prefix (default: /usr/local).
#   --build-dir=PATH       Work directory for sources and build (default: /tmp/opencv-build).
#   --jobs=N               Parallel build jobs (default: number of CPU cores).
#   --swap-size-gb=N       If Jetson detected and swap < N GiB, create a temporary swapfile to reach N GiB (default: 8).
#   --persist-swap         Persist created swapfile in /etc/fstab (Jetson only).
#
# EXIT STATUS
#   0  OpenCV successfully built and installed.
#   1  Failure during removal, dependency install, build, or install steps.
#   2  Usage error / unsupported distribution.
#   >2 Unexpected error; a diagnostic is printed to stderr.

set -euo pipefail

# --------------------------- CLI / Help ---------------------------

QUIET=false
USE_COLOR=true
ASSUME_YES=false

OPENCV_VERSION="4.11.0"
WITH_CONTRIB=true
PREFIX="/usr/local"
BUILD_DIR="/tmp/opencv-build"
JOBS="$(nproc 2>/dev/null || echo 4)"
SWAP_TARGET_GB=8
PERSIST_SWAP=false

print_help() {
  sed -n '1,/^set -euo pipefail/p' "$0" | sed '$d'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --quiet)                 QUIET=true; shift ;;
    --no-color)              USE_COLOR=false; shift ;;
    --help)                  print_help; exit 0 ;;
    --assume-yes)            ASSUME_YES=true; shift ;;
    --opencv-version=*)      OPENCV_VERSION="${1#*=}"; shift ;;
    --contrib)               WITH_CONTRIB=true; shift ;;
    --no-contrib)            WITH_CONTRIB=false; shift ;;
    --prefix=*)              PREFIX="${1#*=}"; shift ;;
    --build-dir=*)           BUILD_DIR="${1#*=}"; shift ;;
    --jobs=*)                JOBS="${1#*=}"; shift ;;
    --swap-size-gb=*)        SWAP_TARGET_GB="${1#*=}"; shift ;;
    --persist-swap)          PERSIST_SWAP=true; shift ;;
    --)                      shift; break ;;
    -*)
      echo "install-opencv.sh: unknown option: $1" >&2
      echo "Try 'install-opencv.sh --help' for more information." >&2
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

current_command=""
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'log_fail "\"$last_command\" failed with exit code $? in $0"' ERR

# --------------------------- Helpers ---------------------------

have_cmd() { command -v "$1" >/dev/null 2>&1; }
is_arm()   { case "$(uname -m)" in aarch64|arm64|armv7*|armv8*|armv6*) return 0 ;; *) return 1 ;; esac; }
is_wsl()   { [[ -f /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; }

need_apt() {
  if [[ -r /etc/os-release ]]; then . /etc/os-release; fi
  case "${ID:-}" in
    ubuntu|debian) return 0 ;;
    *) return 1 ;;
  esac
}

apt_install() {
  local pkgs=("$@"); local y=()
  $ASSUME_YES && y+=("-y")
  sudo apt-get update "${y[@]}"
  sudo apt-get install "${y[@]}" "${pkgs[@]}"
}

fetch_to_tmp() {
  local url="$1" tmp; tmp="$(mktemp -t fetch.XXXXXX.sh)"
  if have_cmd curl; then
    curl -fsSL "$url" -o "$tmp"
  elif have_cmd wget; then
    wget -qO "$tmp" "$url"
  else
    log_fail "Neither curl nor wget found to fetch: $url"
    return 1
  fi
  echo "$tmp"
}

python_exec() { command -v python3 >/dev/null 2>&1 && echo "python3" || echo "python"; }

# --------------------------- Step 0: Remove old OpenCV ---------------------------

remove_old_opencv() {
  log_info "Removing previous OpenCV installations (APT, /usr/local, pip)…"

  if need_apt; then
    local y=()
    $ASSUME_YES && y+=("-y")
    sudo apt-get purge "${y[@]}" 'libopencv*' 'opencv-data' 'python3-opencv' 2>/dev/null || true
    sudo apt-get autoremove "${y[@]}" 2>/dev/null || true
    log_ok "APT OpenCV packages purged (if present)."
  else
    log_warn "Skipping APT purge: unsupported distribution."
  fi

  sudo rm -rf /usr/local/include/opencv4 \
              /usr/local/lib/libopencv_*.so* \
              /usr/local/lib/libopencv_*.a \
              /usr/local/lib/cmake/opencv4 \
              /usr/local/share/opencv* \
              /usr/local/lib/pkgconfig/opencv4.pc 2>/dev/null || true
  log_ok "Removed common /usr/local OpenCV artifacts (if present)."

  if have_cmd pip3; then pip3 uninstall -y opencv-python opencv-contrib-python 2>/dev/null || true; fi
  if have_cmd pip;  then pip  uninstall -y opencv-python opencv-contrib-python 2>/dev/null || true; fi
  log_ok "Uninstalled pip OpenCV wheels (if present)."
}

# --------------------------- Step 1: Detect Jetson & add swap (Jetson) ---------------------------

detect_jetson_runtime() {
  local url="https://raw.githubusercontent.com/EOLab-HSRW/drones/refs/heads/main/public/tools/detect-jetson.sh"
  local tmp; tmp="$(fetch_to_tmp "$url")" || return 1
  chmod +x "$tmp"
  if "$tmp" --quiet; then
    log_ok "Jetson detected by upstream script."
    echo "1"; return 0
  else
    echo "0"; return 1
  fi
}

read_model_dt() {
  if [[ -r /proc/device-tree/model ]]; then
    tr -d $'\0' < /proc/device-tree/model 2>/dev/null || true
  fi
}

ensure_swap_for_jetson() {
  local target_kb=$(( SWAP_TARGET_GB * 1024 * 1024 ))
  local swap_total_kb; swap_total_kb="$(awk '/SwapTotal:/ {print $2}' /proc/meminfo 2>/dev/null || echo 0)"
  if [[ "${swap_total_kb:-0}" -ge "$target_kb" ]]; then
    log_ok "Swap already >= ${SWAP_TARGET_GB} GiB; nothing to do."
    return 0
  fi
  local missing_kb=$(( target_kb - swap_total_kb ))
  local missing_gb=$(( (missing_kb + 1024*1024 -1) / (1024*1024) ))
  log_warn "Swap below target. Creating temporary swapfile to add ~${missing_gb} GiB…"
  sudo fallocate -l "${missing_gb}G" /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1G count="${missing_gb}" status=progress
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  log_ok "Temporary swapfile activated."
  if $PERSIST_SWAP; then
    if ! grep -q '^/swapfile ' /etc/fstab; then
      echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
      log_ok "Swapfile persisted in /etc/fstab."
    else
      log_info "Swapfile already present in /etc/fstab."
    fi
  else
    log_info "Swapfile is NOT persisted (will be lost on reboot). Use --persist-swap to keep it."
  fi
}

ensure_cuda_ldconfig_jetson() {
  # Jetson enhancement: make sure CUDA runtime is found at link time.
  if [[ -d /usr/local/cuda/lib64 ]]; then
    echo '/usr/local/cuda/lib64' | sudo tee /etc/ld.so.conf.d/nvidia-tegra.conf >/dev/null
    sudo ldconfig
    log_ok "Registered /usr/local/cuda/lib64 in dynamic linker config."
  fi
}

maybe_adjust_gcc_for_jetson_nano() {
  # If Jetson Nano detected and GCC >= 9, offer to switch to GCC 8 via update-alternatives (restorable).
  local model="$1"
  [[ "$model" == *"Jetson Nano"* ]] || return 0

  local gcc_major; gcc_major="$(gcc -dumpversion 2>/dev/null | cut -d. -f1 || echo 0)"
  if [[ "${gcc_major:-0}" -ge 9 ]]; then
    log_warn "Detected GCC ${gcc_major} on Jetson Nano; CUDA toolchains often require GCC 8 for compatibility."
    if [[ -x /usr/bin/gcc-8 && -x /usr/bin/g++-8 ]]; then
      if $ASSUME_YES; then
        local proceed="Y"
      else
        read -r -p "Temporarily switch to GCC 8 for this build? (Y/n): " proceed </dev/tty || proceed="n"
      fi
      if [[ "$proceed" =~ ^[Yy]$ ]]; then
        sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 80
        sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 80
        sudo update-alternatives --set gcc /usr/bin/gcc-8
        sudo update-alternatives --set g++ /usr/bin/g++-8
        log_ok "Switched default gcc/g++ to GCC 8 for this session."
      else
        log_fail "Aborting to avoid build failure with incompatible GCC on Jetson Nano."
        exit 1
      fi
    else
      log_warn "GCC 8 not installed. You can install it with: sudo apt-get install gcc-8 g++-8"
      exit 1
    fi
  fi
}

maybe_adjust_jobs_for_jetson() {
  # On Jetson: if swap <= 5.5 GiB, force -j1; else cap at -j4
  local total_swap_mb; total_swap_mb="$(awk '/SwapTotal:/ {print $2/1024}' /proc/meminfo 2>/dev/null || echo 0)"
  if (( $(printf "%.0f" "${total_swap_mb:-0}") > 5500 )); then
    JOBS=4
    log_info "Jetson build: using make -j ${JOBS} (swap > 5.5 GiB)."
  else
    JOBS=1
    log_warn "Jetson build: limited memory/swap; using make -j ${JOBS}."
  fi
}

# --------------------------- Step 2: Check NVIDIA stack ---------------------------

check_nvidia_all_runtime() {
  local url="https://raw.githubusercontent.com/EOLab-HSRW/drones/refs/heads/main/public/tools/check-nvidia.sh"
  local tmp; tmp="$(fetch_to_tmp "$url")" || return 1
  chmod +x "$tmp"
  if "$tmp" --quiet all; then
    log_ok "NVIDIA checker reports: GPU + driver + CUDA present."
    return 0
  else
    log_warn "NVIDIA checker reports missing components."
    return 1
  fi
}

cuda_headers_present() {
  [[ -f /usr/local/cuda/include/cuda_runtime.h ]] || \
  [[ -f /usr/lib/cuda/include/cuda_runtime.h ]]   || \
  [[ -f /usr/include/cuda_runtime.h ]]
}

compute_caps_from_nvidia_smi() {
  if have_cmd nvidia-smi; then
    nvidia-smi --query-gpu=compute_cap --format=csv,noheader 2>/dev/null | tr -d ' ' | paste -sd';' - || true
  fi
}

cudnn_available() { ldconfig -p 2>/dev/null | grep -qi 'libcudnn' || ls /usr/include/*cudnn*.h >/dev/null 2>&1; }

# --------------------------- Step 3: Install build dependencies ---------------------------

install_deps() {
  if need_apt; then
    log_info "Installing build dependencies via APT…"
    # Base build deps
    apt_install build-essential cmake git pkg-config
    # Imaging / codecs / media
    apt_install libjpeg-dev libpng-dev libtiff-dev libglew-dev \
                libavcodec-dev libavformat-dev libswscale-dev \
                libxvidcore-dev libx264-dev libopenexr-dev
    # GUI / V4L2 / GStreamer
    apt_install libgtk-3-dev libgtk2.0-dev libcanberra-gtk-module libcanberra-gtk3-module \
                libv4l-dev v4l-utils gstreamer1.0-tools \
                libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev
    # Math / perf
    apt_install libtbb-dev libtbb2 libeigen3-dev libopenblas-dev libatlas-base-dev \
                liblapacke-dev gfortran
    # Optional extras often used with OpenCV
    apt_install libdc1394-22-dev || true

    # Ubuntu version specific: swresample(22+) vs avresample(<=20)
    if [[ -r /etc/os-release ]]; then . /etc/os-release; fi
    local major="${VERSION_ID%%.*}"
    if [[ -n "$major" && "$major" -ge 22 ]]; then
      apt_install libswresample-dev libdc1394-dev || true
    else
      apt_install libavresample-dev libdc1394-22-dev || true
    fi

    # Python
    apt_install python3-dev python3-numpy python3-pip python3-distutils

    log_ok "Dependencies installed."
  else
    log_warn "Unsupported distro for automatic dependency install. Please install build deps manually."
    return 1
  fi
}

# --------------------------- Step 4: Fetch sources ---------------------------

prepare_sources() {
  local root="$BUILD_DIR"
  mkdir -p "$root"
  # If build dir exists, confirm replacement
  if [[ -d "${root}/build" && "${ASSUME_YES}" != true ]]; then
    echo "Build directory ${root}/build exists and will be reused/replaced."
    read -r -p "Do you wish to continue (Y/n)? " ans </dev/tty || ans="n"
    if [[ ! "$ans" =~ ^[Yy]$ ]]; then
      log_fail "User aborted."
      exit 1
    fi
  fi

  pushd "$root" >/dev/null
  if [[ ! -d opencv ]]; then
    log_info "Cloning OpenCV ${OPENCV_VERSION}…"
    git clone --depth 1 --branch "${OPENCV_VERSION}" https://github.com/opencv/opencv.git
  else
    log_info "opencv/ already exists; skipping clone."
  fi

  if $WITH_CONTRIB; then
    if [[ ! -d opencv_contrib ]]; then
      log_info "Cloning opencv_contrib ${OPENCV_VERSION}…"
      git clone --depth 1 --branch "${OPENCV_VERSION}" https://github.com/opencv/opencv_contrib.git
    else
      log_info "opencv_contrib/ already exists; skipping clone."
    fi
  fi

  mkdir -p "$root/build"
  popd >/dev/null
  log_ok "Sources ready at ${BUILD_DIR}."
}

# --------------------------- Step 5: Configure & build ---------------------------

cmake_configure_and_build() {
  local root="$BUILD_DIR"
  local pyexec; pyexec="$(python_exec)"
  local pypath; pypath="$($pyexec -c 'import site,sys; print(site.getsitepackages()[-1] if site.getsitepackages() else sys.prefix)' 2>/dev/null || echo "/usr/lib/python3/dist-packages")"

  local common_flags=(
    -D CMAKE_BUILD_TYPE=Release
    -D CMAKE_INSTALL_PREFIX="${PREFIX}"
    -D OPENCV_GENERATE_PKGCONFIG=ON
    -D BUILD_EXAMPLES=OFF
    -D BUILD_TESTS=OFF
    -D BUILD_PERF_TESTS=OFF
    -D BUILD_DOCS=OFF
    -D ENABLE_PRECOMPILED_HEADERS=OFF
    -D BUILD_opencv_python3=ON
    -D PYTHON3_EXECUTABLE="$(command -v "$pyexec" || echo /usr/bin/python3)"
    -D PYTHON3_PACKAGES_PATH="${pypath}"
    -D WITH_TBB=ON
    -D WITH_EIGEN=ON
    -D WITH_FFMPEG=ON
    -D WITH_V4L=ON
    -D WITH_GSTREAMER=ON
    -D WITH_QT=OFF
    -D WITH_OPENMP=ON
    -D WITH_PROTOBUF=ON
    -D OPENCV_ENABLE_NONFREE=ON
    -D CMAKE_CXX_FLAGS="-march=native -mtune=native"
    -D CMAKE_C_FLAGS="-march=native -mtune=native"
  )

  # contrib modules
  if $WITH_CONTRIB; then
    common_flags+=(-D OPENCV_EXTRA_MODULES_PATH="${root}/opencv_contrib/modules")
  fi

  # Prefer NEON on ARM/Jetson
  if is_arm; then
    common_flags+=(-D ENABLE_NEON=ON)
  fi

  # Determine CUDA usage
  local use_cuda=false
  local cuda_flags=()
  if check_nvidia_all_runtime && command -v nvcc >/dev/null 2>&1 && cuda_headers_present; then
    use_cuda=true
    cuda_flags+=( -D WITH_CUDA=ON -D CUDA_FAST_MATH=ON -D WITH_CUBLAS=ON -D OPENCV_DNN_CUDA=ON )
    if cudnn_available; then
      cuda_flags+=( -D WITH_CUDNN=ON )
    fi

    # Prefer explicit arch on Jetson if available; else query nvidia-smi
    local JETSON_MODEL=""; JETSON_MODEL="$(read_model_dt || true)"
    if [[ "$JETSON_MODEL" == *"Orin"* ]]; then
      cuda_flags+=( -D CUDA_ARCH_BIN=8.7 -D CUDA_ARCH_PTX=sm_87 )
      log_info "Jetson Orin detected — using CUDA_ARCH_BIN=8.7, CUDA_ARCH_PTX=sm_87"
    elif [[ "$JETSON_MODEL" == *"Jetson Nano"* ]]; then
      cuda_flags+=( -D CUDA_ARCH_BIN=5.3 -D CUDA_ARCH_PTX=sm_53 )
      log_info "Jetson Nano detected — using CUDA_ARCH_BIN=5.3, CUDA_ARCH_PTX=sm_53"
    else
      local caps; caps="$(compute_caps_from_nvidia_smi || true)"
      if [[ -n "$caps" ]]; then
        cuda_flags+=( -D CUDA_ARCH_BIN="${caps}" )
        log_info "Using CUDA_ARCH_BIN=${caps} (from nvidia-smi)."
      fi
    fi
  else
    log_warn "CUDA toolchain or NVIDIA stack not fully available — building CPU-only OpenCV."
    cuda_flags+=( -D WITH_CUDA=OFF )
  fi

  cmake -S "${root}/opencv" -B "${root}/build" "${common_flags[@]}" "${cuda_flags[@]}"

  log_info "Starting build with ${JOBS} parallel job(s)…"
  cmake --build "${root}/build" -- -j"${JOBS}"
  log_ok "Build finished."

  log_info "Installing to ${PREFIX} (sudo may be required)…"
  sudo cmake --install "${root}/build"
  sudo ldconfig
  log_ok "OpenCV installed."
}

# --------------------------- Summary ---------------------------

print_summary() {
  echo -e "${BLUE}======================== OpenCV SUMMARY ========================${NC}" >&2
  echo -e " Prefix          : ${PREFIX}" >&2
  echo -e " Build dir       : ${BUILD_DIR}/build" >&2
  echo -e " Version         : ${OPENCV_VERSION}" >&2
  echo -e " Contrib         : $($WITH_CONTRIB && echo yes || echo no)" >&2
  echo -e " CUDA enabled    : $(pkg-config --modversion opencv4 >/dev/null 2>&1 && \
                         (grep -q 'ENABLE_CUDA.*1' ${BUILD_DIR}/build/CMakeCache.txt 2>/dev/null && echo yes || echo no) || echo n/a)" >&2
  echo -e " pkg-config      : $(pkg-config --modversion opencv4 2>/dev/null || echo 'n/a')" >&2
  echo -e " Python site     : $($(python_exec) -c 'import site,sys; print(site.getsitepackages()[-1] if site.getsitepackages() else sys.prefix)' 2>/dev/null || echo 'n/a')" >&2
  echo -e "${BLUE}===============================================================${NC}" >&2
}

# --------------------------- Main ---------------------------

log_info "Starting OpenCV installation…"

# 0) Ensure basic tools
if ! have_cmd git || ! have_cmd cmake; then
  if need_apt; then
    log_warn "git or cmake not found — installing prerequisites."
    apt_install git cmake
  else
    log_fail "git/cmake missing and cannot auto-install on this distro."
    exit 2
  fi
fi

# 1) Remove old OpenCV
remove_old_opencv

# 2) Detect Jetson; add swap; Jetson-specific tweaks (gcc, ldconfig, jobs)
IS_JETSON=false
if [[ "$(detect_jetson_runtime || echo 0)" == "1" ]]; then
  IS_JETSON=true
  local_model="$(read_model_dt || true)"
  log_info "Jetson model: ${local_model:-unknown}"

  ensure_swap_for_jetson
  ensure_cuda_ldconfig_jetson
  maybe_adjust_gcc_for_jetson_nano "${local_model}"
  maybe_adjust_jobs_for_jetson
fi

# 3) Install build dependencies
install_deps || true

# 4) Prepare sources
prepare_sources

# 5) Configure & build (CUDA if NVIDIA stack is complete; else CPU)
cmake_configure_and_build

# 6) Summary
print_summary

log_ok "Done."
exit 0
