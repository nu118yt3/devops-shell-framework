#!/usr/bin/env bash
set -euo pipefail
APP_NAME="DevOps Shell Framework"
HOSTNAME_VALUE=$(hostname)
DATE_VALUE=$(date '+%Y-%m-%d %H:%M:%S')
USER_VALUE=$(whoami)
cat > app/index.html <<HTML
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>${APP_NAME}</title>
</head>
<body>
  <h1>${APP_NAME}</h1>
  <p>Generado por Shell Scripting.</p>
  <ul>
    <li>Servidor: ${HOSTNAME_VALUE}</li>
    <li>Usuario: ${USER_VALUE}</li>
    <li>Fecha: ${DATE_VALUE}</li>
  </ul>
</body>
</html>
HTML
echo "[OK] Archivo app/index.html generado"
