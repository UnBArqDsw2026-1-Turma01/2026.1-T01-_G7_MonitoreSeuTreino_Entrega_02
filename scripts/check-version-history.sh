#!/usr/bin/env bash

set -euo pipefail

BASE_SHA="${1:-}"
HEAD_SHA="${2:-}"

if [[ -z "$BASE_SHA" || -z "$HEAD_SHA" ]]; then
  echo "Uso: scripts/check-version-history.sh <base-sha> <head-sha>" >&2
  exit 1
fi

extract_history_section() {
  awk '
    BEGIN {
      capture = 0
    }
    /^#{1,6}[[:space:]]+Histórico de Vers(ã|a)o/ {
      capture = 1
      print
      next
    }
    capture && /^#{1,6}[[:space:]]+/ {
      exit
    }
    capture {
      print
    }
  '
}

has_history_section() {
  grep -Eq '^#{1,6}[[:space:]]+Histórico de Vers(ã|a)o'
}

mapfile -t changed_files < <(git diff --name-only --diff-filter=ACMR "$BASE_SHA" "$HEAD_SHA")

tracked_files=()
for file in "${changed_files[@]}"; do
  case "$file" in
    .github/*)
      ;;
    *.md)
      tracked_files+=("$file")
      ;;
  esac
done

if [[ "${#tracked_files[@]}" -eq 0 ]]; then
  echo "Nenhum arquivo Markdown versionado foi alterado neste PR."
  exit 0
fi

failures=0
for file in "${tracked_files[@]}"; do
  if ! git cat-file -e "$HEAD_SHA:$file" 2>/dev/null; then
    continue
  fi

  head_content="$(git show "$HEAD_SHA:$file")"

  if ! has_history_section <<<"$head_content"; then
    echo "::error file=$file::O arquivo alterado precisa conter a secao '## Histórico de Versão'."
    failures=1
    continue
  fi

  head_history="$(extract_history_section <<<"$head_content")"

  if git cat-file -e "$BASE_SHA:$file" 2>/dev/null; then
    base_content="$(git show "$BASE_SHA:$file")"

    if has_history_section <<<"$base_content"; then
      base_history="$(extract_history_section <<<"$base_content")"

      if [[ "$base_history" == "$head_history" ]]; then
        echo "::error file=$file::O arquivo foi alterado, mas a secao 'Histórico de Versão' nao mudou."
        failures=1
      fi
    fi
  fi
done

if [[ "$failures" -ne 0 ]]; then
  exit 1
fi

echo "Historico de versao validado com sucesso."
