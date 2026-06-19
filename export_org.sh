#!/bin/bash

# Script para exportar todos os arquivos .org para HTML usando Emacs em modo batch
# Uso: ./export_org.sh [diretorio]
# Se nenhum diretorio for fornecido, usa o diretorio atual.

TARGET_DIR=${1:-"."}

echo "Iniciando exportação de arquivos .org para HTML em: $TARGET_DIR"

# Verifica se o Emacs está instalado
if ! command -v emacs &> /dev/null; then
    echo "Erro: Emacs não encontrado. Por favor, instale o Emacs para usar este script."
    exit 1
fi

# Localiza e exporta cada arquivo .org
find "$TARGET_DIR" -name "*.org" | while read -r file; do
    echo "Exportando: $file ..."
    
    # Executa o comando de exportação do Emacs
    # --batch: Modo sem interface
    # --eval: Carrega o ox-html
    # -f: Executa a função de exportação
    # --kill: Fecha o Emacs após terminar
    emacs --batch \
          -l export-setup.el \
          "$file" \
          -f org-html-export-to-html \
          --kill 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "Sucesso: ${file%.org}.html criado."
    else
        echo "Falha ao exportar: $file"
    fi
done

echo "Processo concluído!"
