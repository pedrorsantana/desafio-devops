#!/bin/bash

set -euo pipefail

ENV=$1
PACKAGE_PATH=$2

# Verificação de variáveis de ambiente
if [[ -z "${SSH_PRIVATE_KEY:-}" ]]; then
  echo "Erro: SSH_PRIVATE_KEY não está definido"
  exit 1
fi

if [[ -z "${SERVER_IP:-}" ]]; then
  echo "Erro: SERVER_IP não está definido"
  exit 1
fi

# Caminho da chave temporária
KEY_FILE=$(mktemp)

# Escreve a chave no arquivo temporário
echo "$SSH_PRIVATE_KEY" > "$KEY_FILE"
chmod 600 "$KEY_FILE"

# Defina o destino remoto e o diretório de destino
REMOTE_USER="deployer"
REMOTE_DIR="/var/www/html"

# Envia os arquivos para o servidor
echo "Transferindo pacote para $REMOTE_USER@$SERVER_IP:$REMOTE_DIR"
scp -i "$KEY_FILE" -r "$PACKAGE_PATH"/* "$REMOTE_USER@$SERVER_IP:$REMOTE_DIR"

# Reinicia o nginx no servidor remoto
echo "Reiniciando nginx em $SERVER_IP"
ssh -i "$KEY_FILE" "$REMOTE_USER@$SERVER_IP" << 'EOF'
  sudo systemctl reload nginx
EOF

# Remove a chave temporária
rm -f "$KEY_FILE"

echo "Deploy finalizado com sucesso."
