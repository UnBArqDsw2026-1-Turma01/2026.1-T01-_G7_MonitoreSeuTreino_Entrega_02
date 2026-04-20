# Contributing

## Fluxo de branches

- `main`: branch protegida. Nao aceita commits diretos e so deve receber PR originado da branch `dev`.
- `main`: todo PR para essa branch precisa de pelo menos 1 review de aprovacao antes do merge.
- `dev`: branch protegida, mas aceita commits diretos.
- `dev`: pode receber PR de qualquer branch de trabalho e nao exige review para merge.
- Branches de trabalho devem abrir PR para `dev`.

## Regras para PRs

- Se voce alterou arquivos Markdown versionados, atualize a secao `## Histórico de Versão` dos arquivos alterados.
- PRs para `main` que nao saiam da branch `dev` serao bloqueados pelo CI.
- PRs para `dev` e `main` executam o check de historico de versao.

## Padrao do historico de versao

Todo arquivo Markdown versionado no repositório, exceto arquivos dentro de `.github/`, deve manter uma secao chamada `## Histórico de Versão`.

Formato recomendado:

| Data | Versao | Descricao | Autor |
| --- | --- | --- | --- |
| 2026-04-20 | 0.1 | Criacao ou atualizacao inicial do artefato. | Equipe |

## Histórico de Versão

| Data | Versao | Descricao | Autor |
| --- | --- | --- | --- |
| 2026-04-20 | 1.0 | Define o fluxo de branches, revisoes e a regra de historico de versao do repositório. | Lucas Antunes |
