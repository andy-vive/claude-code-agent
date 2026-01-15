# Claude Code Agent Coordination

A domain-agnostic framework for coordinating specialized Claude Code agents in implement-then-review workflows. Orchestrate engineer/reviewer agent pairs for any domain: DevOps, backend, frontend, security, and more.

## Features

- **Agent Coordination Protocol**: Systematic workflow for multi-agent task execution
- **Extensible Agent System**: Engineer/reviewer pairs for any domain (DevOps, backend, frontend, security, etc.)
- **Work Registries**: Track completed work and technical debt across sessions
- **Verification Scripts**: Automated validation of agent outputs and deliverables
- **Custom Skills & Commands**: Reusable workflows like Terraform/Terragrunt implementation and code reviews

## Current Agent Pairs

- **DevOps**: CI/CD pipelines, containerization, monitoring, deployment automation
- **Specification**: Document creation and review for requirements and specs
- **Infrastructure**: Terraform/Terragrunt implementation (via custom command)

## Extensible to Any Domain

The protocol supports adding new agent pairs without modification:
- Backend (API development, database design)
- Frontend (UI components, state management)
- Security (vulnerability assessment, secure coding)
- Testing (test creation, test review)
- And more...

## Quick Start

1. Place agent definitions in `agents/` directory
2. Use the `/agent-coordination` skill to orchestrate multi-agent tasks
3. Reports are generated in `.claude/reports/` with automatic registry updates

## Project Structure

```
.
├── agents/              # Agent definitions (engineer/reviewer pairs)
├── commands/            # Reusable command definitions
├── skills/              # Coordination protocol and utilities
│   └── agent-coordination/
│       ├── scripts/     # Verification and archiving scripts
│       └── templates/   # Report templates
└── .claude/reports/     # Generated work reports and registries (created at runtime)
```

## Documentation

- [Agent Coordination Protocol](skills/agent-coordination/SKILL.md) - Core workflow and registry management
- [Templates](skills/agent-coordination/templates.md) - Report templates for all categories
- [Reference](skills/agent-coordination/reference.md) - Detailed verification and edge case handling
