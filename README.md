# Opencode Skills

Repositório pessoal de **skills** para o [Opencode](https://opencode.ai) — um assistente CLI de engenharia de software.

Skills são instruções especializadas que ensinam o Opencode a executar tarefas complexas de forma consistente e profissional.

## Estrutura

```
opencode-skills/
├── skills/              # Skills organizadas por pasta
│   ├── business-rules/
│   ├── crisp-dm-dev-standards/
│   ├── doc-generator/
│   ├── lgpd-scanner/
│   ├── opencode-output-path/
│   ├── project-scanner/
│   └── windows-protection/
├── config/              # Arquivos de configuração do Opencode
├── scripts/             # Utilitários de instalação e manutenção
└── README.md
```

## Skills disponíveis

| Skill | Descrição |
|-------|-----------|
| [business-rules](skills/business-rules/) | Extrai regras de negócio de projetos em formato IF/THEN |
| [crisp-dm-dev-standards](skills/crisp-dm-dev-standards/) | Padrões de desenvolvimento CRISP-DM, PEP 8, Clean Code |
| [doc-generator](skills/doc-generator/) | Gera documentação HTML/PDF a partir de relatórios JSON |
| [lgpd-scanner](skills/lgpd-scanner/) | Scanner de conformidade LGPD/GDPR em projetos |
| [opencode-output-path](skills/opencode-output-path/) | Define D:\Opencode\ como diretório padrão para todas as saídas do opencode |
| [project-scanner](skills/project-scanner/) | Mapeia estrutura, linguagens e arquitetura de projetos |
| [windows-protection](skills/windows-protection/) | Protege arquivos do sistema Windows contra modificação |

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
