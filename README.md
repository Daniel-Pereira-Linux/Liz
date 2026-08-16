# ☕ LIZ — O Gerador de ISO Definitivo

![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Em_Testes-orange.svg?style=for-the-badge)

O **LIZ** é um orquestrador extremamente enxuto e direto, escrito **100% em Bash puro**, projetado com um único propósito: pegar o seu sistema Linux atual e transformá-lo em uma ISO instalável e incrivelmente compacta. Sem dependências complexas (sem Node.js, Python ou TypeScript), sem frameworks pesados, apenas a essência do mundo Linux.

> **⚠️ FASE DE TESTES (BETA):** O projeto está em fase de testes. Qualquer bug, erro ou comportamento inesperado deve ser relatado via **Issues** aqui no GitHub. Ajude a lapidar o Liz!
>
> **🐧 NOTA DE COMPATIBILIDADE:** O LIZ foi criado e homologado para uso especificamente no **Debian 13**. Ainda não validamos a eficácia do script em outras distribuições (Ubuntu, Arch, Fedora, etc). Por segurança e estabilidade, recomendamos o uso no Debian 13. Caso queira se aventurar e testar em outras distribuições, fique à vontade, mas faça por sua própria conta e risco! Estamos também estudando formas de diminuir ainda mais o tamanho final da ISO.

---

## 🌟 Por que o LIZ é diferente?

- **Compressão Absoluta:** O Liz utiliza o `mksquashfs` com o algoritmo **zstd no nível 22** (a compressão máxima existente no mercado). Suas ISOs ficarão minúsculas sem sacrificar a velocidade de descompressão na hora de instalar.
- **Interface ASCII Elegante:** Sem telas poluídas cheias de logs intermináveis rolando. O Liz suprime o "ruído" do terminal e exibe apenas uma barra de progresso com um cafézinho ASCII enquanto a ISO é gerada.
- **Suporte Híbrido:** Gera ISOs bootáveis tanto para **UEFI** (via GRUB) quanto para **BIOS Legacy** (via ISOLINUX).
- **Integração com Calamares:** O Liz já traz configurações pré-prontas do Calamares. Se você tem o Calamares instalado no seu sistema, o Liz automaticamente o transforma no instalador gráfico da sua nova distro.
- **Análise Inteligente:** O comando `--depends` analisa o seu sistema (Rocky Linux, Debian, Ubuntu, Arch) e diz exatamente o que falta sem forçar a instalação.

---

## 🚀 Como usar

### 1. Requisitos
O Liz precisa de ferramentas como `squashfs-tools`, `xorriso`, `grub` e o próprio `calamares`. Mas não se preocupe, nós temos um instalador inteligente.

```bash
# Clone o repositório
git clone https://github.com/Daniel-Pereira-Linux/Liz.git
cd Liz

# Deixe o script instalar as dependências
sudo ./install.sh
```

### 2. Verifique as dependências
Certifique-se de que tudo está em ordem (o Liz dirá o que falta):
```bash
liz --depends
```

### 3. Gere sua ISO
É só rodar e ir tomar um café:
```bash
sudo liz build
```

Quer personalizar o nome da sua distro? Sem problemas:
```bash
sudo LIZ_ISO_NAME="minha-distro" LIZ_ISO_VERSION="1.5" liz build
```

Sua ISO estará pronta na partição `/home/liz-output/` (seguro para não encher a raiz).

---

## 📁 Estrutura do Projeto

```text
liz/
├── liz                      ← Script principal (onde a mágica acontece)
├── install.sh               ← Instalador automático de dependências
├── calamares/               ← Arquivos de configuração e tema pro instalador
├── grub/                    ← Configurações de boot UEFI
├── isolinux/                ← Configurações de boot BIOS Legacy
└── LICENSE                  ← Licença do projeto
```

---

## ⚖️ Licença e Créditos

Este projeto é software livre licenciado sob a **GNU GPLv3**. Você tem a liberdade de usar, estudar, modificar e compartilhar.

> **Importante:** Se você utilizar, forkar ou modificar este projeto, **os créditos originais devem sempre ser atribuídos ao criador**.

Criado e mantido com ☕ por **Daniel Silva (Daniel Pereira Linux)**.
