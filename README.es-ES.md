

# Coordinación de Agentes Claude Code

Un framework agnóstico al dominio para coordinar agentes especializados de Claude Code en flujos de trabajo de implementación y revisión. Orquesta pares de agentes ingeniero/revisor para cualquier dominio: DevOps, backend, frontend, seguridad y más.

## Características

- **Protocolo de Coordinación de Agentes**: Flujo de trabajo sistemático para la ejecución de tareas multi-agente
- **Sistema de Agentes Extensible**: Pares ingeniero/revisor para cualquier dominio (DevOps, backend, frontend, seguridad, etc.)
- **Registros de Trabajo**: Seguimiento del trabajo completado y la deuda técnica entre sesiones
- **Scripts de Verificación**: Validación automatizada de las salidas y entregables de los agentes
- **Habilidades y Comandos Personalizados**: Flujos de trabajo reutilizables como la implementación con Terraform/Terragrunt y revisiones de código
- **Experiencia Especializada por Dominio**: Habilidades especializadas para NestJS, infraestructura y más

## Habilidades Disponibles

### Coordinación de Agentes
- **agent-coordination**: Protocolo central de orquestación para flujos de trabajo multi-agente

### Desarrollo Backend
- **nestjs-expert**: Desarrollo empresarial con NestJS con arquitectura modular, inyección de dependencias, patrones CQRS y pruebas integrales

## Pares de Agentes Actuales

- **DevOps**: Pipelines CI/CD, contenedores, monitoreo, automatización de despliegues
- **Especificación**: Creación y revisión de documentos para requisitos y especificaciones

## Comandos Disponibles

- **terraform-terragrunt**: Implementación de infraestructura como código
- **review-devops**: Revisión de código de infraestructura para seguridad, escalabilidad y mejores prácticas

## Extensible a Cualquier Dominio

El protocolo admite la adición de nuevos pares de agentes sin modificaciones:
- Backend (desarrollo de APIs, diseño de bases de datos)
- Frontend (componentes de UI, gestión de estado)
- Seguridad (evaluación de vulnerabilidades, codificación segura)
- Pruebas (creación de pruebas, revisión de pruebas)
- Y más...

## Inicio Rápido

### Uso de la Coordinación de Agentes
1. Coloca las definiciones de agentes en el directorio `agents/`
2. Usa la habilidad `/agent-coordination` para orquestar tareas multi-agente
3. Los informes se generan en `.claude/reports/` con actualizaciones automáticas del registro

### Uso de Habilidades por Dominio
- **Desarrollo NestJS**: Usa `/nestjs-expert` para crear backends en TypeScript de nivel empresarial
- **Infraestructura**: Usa el comando `/terraform-terragrunt` para la implementación de IaC
- **Revisión DevOps**: Usa el comando `/review-devops` para revisiones de código de infraestructura

## Estructura del Proyecto

```
.
├── agents/              # Definiciones de agentes (pares ingeniero/revisor)
│   ├── devops-engineer.md
│   ├── devops-reviewer.md
│   ├── spec-creator.md
│   └── spec-reviewer.md
├── commands/            # Definiciones de comandos reutilizables
│   ├── terraform-terragrunt.md
│   └── review-devops.md
├── skills/              # Habilidades especializadas y protocolos de coordinación
│   ├── agent-coordination/
│   │   ├── scripts/     # Scripts de verificación y archivado
│   │   ├── templates/   # Plantillas de informes
│   │   └── SKILL.md     # Protocolo de coordinación
│   └── nestjs-expert/
│       ├── references/  # Documentación de referencia de NestJS
│       └── SKILL.md     # Flujo de trabajo de desarrollo NestJS
└── .claude/reports/     # Informes de trabajo y registros generados (creados en tiempo de ejecución)
```

## Documentación

### Coordinación de Agentes
- [Protocolo de Coordinación de Agentes](skills/agent-coordination/SKILL.md) - Flujo de trabajo central y gestión de registros
- [Plantillas](skills/agent-coordination/templates.md) - Plantillas de informes para todas las categorías
- [Referencia](skills/agent-coordination/reference.md) - Verificación detallada y manejo de casos extremos

### Desarrollo NestJS
- [Habilidad NestJS Expert](skills/nestjs-expert/SKILL.md) - Flujo de trabajo central de NestJS y mejores prácticas
- [Estructura del Proyecto](skills/nestjs-expert/references/structure.md) - Organización y arquitectura de módulos
- [Controladores](skills/nestjs-expert/references/controller.md) - Controladores de API REST y enrutamiento
- [Patrón CQRS](skills/nestjs-expert/references/cqrs.md) - Comandos, consultas y eventos
- [Servicios](skills/nestjs-expert/references/service.md) - Inyección de dependencias y proveedores
- [DTOs y Validación](skills/nestjs-expert/references/dto.md) - Validación de entrada y objetos de transferencia de datos
- [Pruebas](skills/nestjs-expert/references/testing.md) - Estrategias de pruebas unitarias y E2E
