#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  install.sh — Instalador do liz
#  Instala dependências e coloca liz em /usr/local/bin
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

C_RESET='\033[0m'
C_BOLD='\033[1m'
C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_RED='\033[0;31m'
C_YELLOW='\033[0;33m'
C_BRIGHT_WHITE='\033[1;37m'
C_BRIGHT_GREEN='\033[1;32m'

log_info()    { echo -e "  ${C_CYAN}→${C_RESET} $*"; }
log_ok()      { echo -e "  ${C_BRIGHT_GREEN}✓${C_RESET} $*"; }
log_warn()    { echo -e "  ${C_YELLOW}⚠${C_RESET} $*"; }
log_error()   { echo -e "  ${C_RED}✗${C_RESET} $*"; }
log_section() { echo -e "\n${C_BOLD}${C_BRIGHT_WHITE}$*${C_RESET}"; }

# ─── Root check ──────────────────────────────────────────────────────────────
if [[ "${EUID}" -ne 0 ]]; then
  log_error "Este instalador requer root. Use: sudo ./install.sh"
  exit 1
fi

# ─── Detecta distro ──────────────────────────────────────────────────────────
detect_family() {
  if command -v apt-get &>/dev/null; then
    echo "debian"
  elif command -v dnf &>/dev/null; then
    echo "fedora"
  elif command -v pacman &>/dev/null; then
    echo "arch"
  else
    echo "unknown"
  fi
}

FAMILY=$(detect_family)

echo -e "\n${C_CYAN}${C_BOLD}"
cat << 'EOF'
  ╔══════════════════════════════════════════════════════════╗
  ║           liz — Instalador de Dependências             ║
  ╚══════════════════════════════════════════════════════════╝
EOF
echo -e "${C_RESET}"

# ─── Instala dependências ────────────────────────────────────────────────────
log_section "1. Instalando dependências do sistema"

case "${FAMILY}" in
  debian)
    log_info "Sistema Debian/Ubuntu detectado. Atualizando pacotes..."
    apt-get update -qq >/dev/null 2>&1
    log_info "Instalando sistema base live (live-boot, live-config)..."
    apt-get install -y -qq live-boot live-config live-config-systemd >/dev/null 2>&1 \
      || log_warn "Falha ao instalar live-boot/live-config (Sua ISO pode não fazer login automático)"

    log_info "Instalando squashfs-tools-ng (zstd support)..."
    apt-get install -y -qq squashfs-tools-ng >/dev/null 2>&1 \
      || apt-get install -y -qq squashfs-tools >/dev/null 2>&1 \
      && log_ok "squashfs instalado" \
      || log_warn "Falha ao instalar squashfs-tools-ng — instale manualmente"

    log_info "Instalando xorriso..."
    apt-get install -y -qq xorriso >/dev/null 2>&1 \
      && log_ok "xorriso instalado" \
      || log_warn "Falha ao instalar xorriso"

    log_info "Instalando grub (bios + efi) e mtools..."
    apt-get install -y -qq grub-common mtools >/dev/null 2>&1 || true
    apt-get install -y -qq grub-pc-bin >/dev/null 2>&1 || log_warn "grub-pc-bin não instalado (BIOS boot pode falhar)"
    apt-get install -y -qq grub-efi-amd64-bin >/dev/null 2>&1 || log_warn "grub-efi-amd64-bin não instalado (UEFI boot pode falhar)"

    log_info "Instalando isolinux/syslinux..."
    apt-get install -y -qq isolinux syslinux syslinux-common >/dev/null 2>&1 \
      && log_ok "isolinux instalado" \
      || log_warn "Falha ao instalar isolinux"

    log_info "Instalando Calamares (instalador gráfico)..."
    apt-get install -y -qq calamares calamares-settings-debian >/dev/null 2>&1 \
      || apt-get install -y -qq calamares >/dev/null 2>&1 \
      && log_ok "calamares instalado" \
      || log_warn "Calamares não disponível neste repo — instale manualmente"
    ;;

  fedora)
    log_info "Sistema Fedora/RHEL detectado..."
    dnf install -y -q squashfs-tools xorriso grub2-tools-extra calamares >/dev/null 2>&1 \
      && log_ok "Dependências instaladas via dnf" \
      || log_warn "Algumas dependências podem ter falhado — verifique manualmente"
    ;;

  arch)
    log_info "Sistema Arch detectado..."
    pacman -S --noconfirm --needed squashfs-tools libisoburn syslinux calamares >/dev/null 2>&1 \
      && log_ok "Dependências instaladas via pacman" \
      || log_warn "Algumas dependências podem ter falhado — verifique manualmente"
    ;;

  *)
    log_warn "Distro não reconhecida. Instale manualmente:"
    echo "    • mksquashfs (squashfs-tools ou squashfs-tools-ng)"
    echo "    • xorriso"
    echo "    • grub-mkrescue"
    echo "    • isolinux / syslinux"
    echo "    • calamares"
    ;;
esac

# ─── Instala liz ───────────────────────────────────────────────────────────
log_section "2. Instalando liz"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIZ_SRC="${SCRIPT_DIR}/liz"
LIZ_DEST="/usr/local/bin/liz"

if [[ ! -f "${LIZ_SRC}" ]]; then
  log_error "Arquivo 'liz' não encontrado em ${SCRIPT_DIR}"
  exit 1
fi

log_info "Copiando liz para ${LIZ_DEST}..."
install -m 755 "${LIZ_SRC}" "${LIZ_DEST}"
log_ok "liz instalado em ${LIZ_DEST}"

# ─── Copia configurações do Calamares ────────────────────────────────────────
log_section "3. Configurando Calamares"

CALAMARES_SRC="${SCRIPT_DIR}/calamares"
CALAMARES_DEST="/etc/calamares"

if [[ -d "${CALAMARES_SRC}" ]]; then
  log_info "Copiando configurações do Calamares..."
  mkdir -p "${CALAMARES_DEST}"
  cp -r "${CALAMARES_SRC}/." "${CALAMARES_DEST}/"
  log_ok "Configurações do Calamares instaladas em ${CALAMARES_DEST}"
else
  log_warn "Pasta calamares/ não encontrada — usando configuração existente do sistema"
fi

# ─── Resumo ──────────────────────────────────────────────────────────────────
echo -e "\n${C_BRIGHT_GREEN}${C_BOLD}"
cat << 'EOF'
  ╔══════════════════════════════════════════════════════════╗
  ║   ✓  Instalação concluída!                               ║
  ╠══════════════════════════════════════════════════════════╣
  ║                                                          ║
  ║   Para gerar sua ISO, execute:                           ║
  ║                                                          ║
  ║     sudo liz build                                     ║
  ║                                                          ║
  ║   Personalize o nome da ISO:                             ║
  ║                                                          ║
  ║     sudo LIZ_ISO_NAME=minha-distro liz build         ║
  ║                                                          ║
  ╚══════════════════════════════════════════════════════════╝
EOF
echo -e "${C_RESET}"
