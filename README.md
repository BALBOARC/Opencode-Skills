# Opencode Skills

Repositório pessoal de **skills** para o [Opencode](https://opencode.ai) — um assistente CLI de engenharia de software.

Skills são instruções especializadas que ensinam o Opencode a executar tarefas complexas de forma consistente e profissional.

## Estrutura

```
opencode-skills/
├── skills/              # Skills organizadas por pasta
│   ├── business-analyzer/
│   └── ...              # Adicione novas skills aqui
├── config/              # Arquivos de configuração do Opencode
├── scripts/             # Utilitários de instalação e manutenção
└── README.md
```

## Skills disponíveis

| Skill | Descrição |
|-------|-----------|
| [business-analyzer](skills/business-analyzer/) | Analisa projetos, extrai regras de negócio e gera documentação técnica em PDF |

## Como instalar em uma máquina nova

```bash
# 1. Clonar o repositório
git clone git@github.com:BALBOARC/Opencode-Skills.git ~/Opencode-Skills

# 2. Executar o instalador
bash ~/Opencode-Skills/scripts/install.sh
```

O instalador cria os diretórios e copia as skills para o local correto (`~/.config/opencode/skills/`).

## Como criar uma nova skill

1. Copie o template: `cp -r skills/_template skills/minha-skill`
2. Edite `skills/minha-skill/SKILL.md` com as instruções da skill
3. Edite `skills/minha-skill/README.md` com a descrição
4. Commit e push
