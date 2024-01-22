#!/bin/bash
# read-only.sh - valida se os discos estão em read-only ou read-write
#
# Autor: https://www.linkedin.com/in/luiz-costa-710810a0/
#

# Obtém informações sobre os pontos de montagem
mount_info=$(mount)

# Obtém uma lista de todos os dispositivos listados no comando df -h
dispositivos=$(df -h | awk '$1 ~ /^\// {print $1}')

# Adiciona expressões regulares para filtrar discos NFS
dispositivos_nfs=$(echo "$mount_info" | awk '$1 ~ /^.+:.+/ && $3 ~ /^\// {print $1}')

# Combina as listas de dispositivos
dispositivos+=" $dispositivos_nfs"

# Remove duplicatas, se houver
dispositivos=$(echo "$dispositivos" | tr ' ' '\n' | sort -u)

# Inicializa um array associativo para armazenar os resultados
declare -A resultados

# Inicializa a variável read_only
read_only=0

# Itera sobre cada dispositivo
for dispositivo in $dispositivos; do
    # Obtém informações sobre o ponto de montagem
    ponto_montagem=$(df -h | awk -v device="$dispositivo" '$1 == device {print $6}')

    # Verifica se o dispositivo está em modo somente leitura ou leitura e escrita
    if mount_info=$(mount | grep -E "^$dispositivo" | grep -E '\<(rw|ro)\>'); then
        status=$(echo "$mount_info" | grep -o -E '\<(rw|ro)\>')
        if [ "$status" = 'ro' ]; then
            read_only=1
        fi
    fi

    # Adiciona os resultados ao array associativo
    json+="{ \"device\": \"$dispositivo\", \"mount_point\": \"$ponto_montagem\", \"read_only\": $read_only },"
    read_only=0
done

# Converte o array associativo em uma string JSON
json="[${json%,}]"

# printa o JSON final
echo "$json"
