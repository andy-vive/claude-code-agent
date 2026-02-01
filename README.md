# Claude Code Agent Coordination

A domain-agnostic framework for coordinating specialized Claude Code agents in implement-then-review workflows. Orchestrate engineer/reviewer agent pairs for any domain: DevOps, backend, frontend, security, and more.

## Features

- **Agent Coordination Protocol**: Systematic workflow for multi-agent task execution
- **Extensible Agent System**: Engineer/reviewer pairs for any domain (DevOps, backend, frontend, security, etc.)
- **Work Registries**: Track completed work and technical debt across sessions
- **Verification Scripts**: Automated validation of agent outputs and deliverables
- **Custom Skills & Commands**: Reusable workflows like Terraform/Terragrunt implementation and code reviews
- **Domain-Specific Expertise**: Specialized skills for NestJS, infrastructure, and more

## Available Skills

### Agent Coordination
- **agent-coordination**: Core orchestration protocol for multi-agent workflows

### Backend Development
- **nestjs-expert**: Enterprise NestJS development with modular architecture, dependency injection, CQRS patterns, and comprehensive testing

## Current Agent Pairs

- **DevOps**: CI/CD pipelines, containerization, monitoring, deployment automation
- **Specification**: Document creation and review for requirements and specs

## Available Commands

- **terraform-terragrunt**: Infrastructure as code implementation
- **review-devops**: Infrastructure code review for security, scalability, and best practices

## Extensible to Any Domain

The protocol supports adding new agent pairs without modification:
- Backend (API development, database design)
- Frontend (UI components, state management)
- Security (vulnerability assessment, secure coding)
- Testing (test creation, test review)
- And more...

## Quick Start

### Using Agent Coordination
1. Place agent definitions in `agents/` directory
2. Use the `/agent-coordination` skill to orchestrate multi-agent tasks
3. Reports are generated in `.claude/reports/` with automatic registry updates

### Using Domain Skills
- **NestJS Development**: Use `/nestjs-expert` for building enterprise-grade TypeScript backends
- **Infrastructure**: Use `/terraform-terragrunt` command for IaC implementation
- **DevOps Review**: Use `/review-devops` command for infrastructure code reviews

## Project Structure

```
.
├── agents/              # Agent definitions (engineer/reviewer pairs)
│   ├── devops-engineer.md
│   ├── devops-reviewer.md
│   ├── spec-creator.md
│   └── spec-reviewer.md
├── commands/            # Reusable command definitions
│   ├── terraform-terragrunt.md
│   └── review-devops.md
├── skills/              # Specialized skills and coordination protocols
│   ├── agent-coordination/
│   │   ├── scripts/     # Verification and archiving scripts
│   │   ├── templates/   # Report templates
│   │   └── SKILL.md     # Coordination protocol
│   └── nestjs-expert/
│       ├── references/  # NestJS reference documentation
│       └── SKILL.md     # NestJS development workflow
└── .claude/reports/     # Generated work reports and registries (created at runtime)
```

## Documentation

### Agent Coordination
- [Agent Coordination Protocol](skills/agent-coordination/SKILL.md) - Core workflow and registry management
- [Templates](skills/agent-coordination/templates.md) - Report templates for all categories
- [Reference](skills/agent-coordination/reference.md) - Detailed verification and edge case handling

### NestJS Development
- [NestJS Expert Skill](skills/nestjs-expert/SKILL.md) - Core NestJS workflow and best practices
- [Project Structure](skills/nestjs-expert/references/structure.md) - Module organization and architecture
- [Controllers](skills/nestjs-expert/references/controller.md) - REST API controllers and routing
- [CQRS Pattern](skills/nestjs-expert/references/cqrs.md) - Commands, queries, and events
- [Services](skills/nestjs-expert/references/service.md) - Dependency injection and providers
- [DTOs & Validation](skills/nestjs-expert/references/dto.md) - Input validation and data transfer objects
- [Testing](skills/nestjs-expert/references/testing.md) - Unit and E2E testing strategies
