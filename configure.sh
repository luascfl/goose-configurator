#!/bin/bash

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

CONFIG_FILE="$HOME/.config/goose/config.yaml"
BASHRC="$HOME/.bashrc"
CURRENT_KEY="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"
DEFAULT_MODEL="mistralai/devstral-2512:free"

echo -e "${BLUE}=== Configurador do Goose (OpenRouter) ===${NC}"

# 1. Solicitar Modelo
echo -e "\nQual modelo você deseja usar? (Exemplos: google/gemini-2.0-flash-exp:free, deepseek/deepseek-chat)"
read -p "Modelo [Pressione Enter para '$DEFAULT_MODEL']: " MODEL_INPUT
MODEL=${MODEL_INPUT:-$DEFAULT_MODEL}

# 2. Solicitar API Key
echo -e "\nQual sua API Key do OpenRouter?"
read -p "Key [Pressione Enter para manter a atual]: " KEY_INPUT
API_KEY=${KEY_INPUT:-$CURRENT_KEY}

echo -e "\n${BLUE}Configurando para:${NC}"
echo "Provider: openrouter"
echo "Modelo:   $MODEL"
echo "Key:      ${API_KEY:0:10}..."

# 3. Atualizar config.yaml
echo -e "\n${GREEN}[1/2] Atualizando $CONFIG_FILE...${NC}"
mkdir -p "$(dirname "$CONFIG_FILE")"
cat <<EOF > "$CONFIG_FILE"
provider: openrouter
model: $MODEL

providers:
  openrouter:
    type: openai
    base_url: "https://openrouter.ai/api/v1"
    models:
      - "$MODEL"
EOF

# 4. Atualizar .bashrc
echo -e "${GREEN}[2/2] Atualizando $BASHRC...${NC}"

# Define marcadores para facilitar atualizações futuras
MARKER_START="# --- GOOSE CONFIG START ---"
MARKER_END="# --- GOOSE CONFIG END ---"

# Remove bloco antigo com marcadores (se existir)
sed -i "/$MARKER_START/,/$MARKER_END/d" "$BASHRC"

# Remove linhas soltas antigas que adicionamos manualmente antes
sed -i '/# Configuração Permanente do Goose/d' "$BASHRC"
sed -i '/export GOOSE_PROVIDER=/d' "$BASHRC"
sed -i '/export OPENAI_BASE_URL=/d' "$BASHRC"
sed -i '/export OPENAI_API_KEY=/d' "$BASHRC"
sed -i '/export GOOSE_MODEL=/d' "$BASHRC"

# Adiciona novo bloco limpo
cat <<EOF >> "$BASHRC"
$MARKER_START
# Configuração gerada pelo script configurar_goose.sh
export GOOSE_PROVIDER=openrouter
export OPENAI_BASE_URL="https://openrouter.ai/api/v1"
export OPENAI_API_KEY="$API_KEY"
export GOOSE_MODEL="$MODEL"
$MARKER_END
EOF

echo -e "\n${GREEN}=== Sucesso! ===${NC}"
echo "Para aplicar as mudanças agora, execute:"
echo -e "${BLUE}source ~/.bashrc && goose session${BLUE}"
