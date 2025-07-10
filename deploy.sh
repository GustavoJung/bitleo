#!/bin/bash

# Configurações
REPO_NAME="bitleo"
OUTPUT_DIR="docs"

echo "👉 Fazendo build do Flutter Web com base href /$REPO_NAME/..."
flutter build web --base-href="/$REPO_NAME/"

echo "🗂️ Criando pasta $OUTPUT_DIR se não existir..."
mkdir -p $OUTPUT_DIR

echo "🧹 Limpando conteúdo antigo da pasta $OUTPUT_DIR..."
rm -rf $OUTPUT_DIR/*

echo "📦 Copiando build para $OUTPUT_DIR..."
cp -r build/web/* $OUTPUT_DIR/

echo "🚫 Criando .nojekyll para evitar build Jekyll do GitHub Pages..."
touch $OUTPUT_DIR/.nojekyll

echo "🧼 Limpando a pasta de build temporária (opcional)..."
rm -rf build

echo "📤 Commitando alterações..."
git add .
git commit -m "Deploy para GitHub Pages via docs"
git push origin gh-pages

echo "🚀 Deploy atualizado na pasta /docs! Só ir nas configs do GitHub Pages e garantir que está usando ela 🎯"
