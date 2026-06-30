# Business Analyzer

Skill para análise completa de projetos com geração de documentação profissional em PDF.

## O que faz

- Mapeia a estrutura do projeto (linguagens, frameworks, arquitetura)
- Extrai regras de negócio com identificação única (BR-001, BR-002...)
- Gera **PDF de Regras de Negócio** — para stakeholders e área de negócio
- Gera **PDF de Documentação Técnica** — para desenvolvedores e devops
- Avalia conformidade com **LGPD** (Lei Geral de Proteção de Dados)
- Analisa qualidade de código (SOLID, design patterns, segurança)

## Como usar

No terminal, dentro do projeto a ser analisado:

```
@opencode analyze this project and generate business documentation
```

Ou em português:

```
@opencode analise este projeto e gere a documentação de regras de negócio
```

## Requisitos

- [WeasyPrint](https://doc.courtbouillon.org/weasyprint/) instalado para geração de PDF:
  ```bash
  pip install weasyprint
  ```

## Saída

A skill gera na pasta de saída:

```
{projeto}/
├── business-rules-{projeto}.pdf
├── business-rules-{projeto}.html
├── technical-docs-{projeto}.pdf
├── technical-docs-{projeto}.html
└── resumo-analise-{projeto}.md
```
