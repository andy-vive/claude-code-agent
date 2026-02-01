# Baseline Folder Structure

## Project Root
```
project-root/
├── src/                          # Source code
├── test/                         # Tests
├── migrations/                   # Database migrations
├── seeds/                        # Database seed files
├── package.json                  # Project dependencies
├── tsconfig.json                 # TypeScript configuration
├── jest.config.ts                # Jest configuration
├── nest-cli.json                 # NestJS CLI configuration
├── ormconfig.ts                  # TypeORM configuration
├── docker-compose.yaml           # Docker compose
├── Dockerfile.build              # Docker configuration
├── Dockerfile.test               # Docker configuration
└── README.md                     # Project documentation
```

## Source Directory Structure (`src/`)

### Core Directories
```
src/
├── main.ts                       # Application entry point
├── app.module.ts                 # Root application module
│
├── config/                       # Configuration files
│   ├── database.config.ts
│   ├── redis.config.ts
│   ├── aws.config.ts
│   └── microservices/            # Microservice configurations
│
├── common/                       # Shared utilities and framework concerns
│   ├── constant/                 # Global constants
│   ├── dto/                      # Base DTOs, pagination DTOs
│   └── services/                 # Framework services (logging, HTTP client)
│
├── shared/                       # Shared business logic
│   ├── enum/                     # Application enums
│   ├── models/                   # Value objects, shared DTOs
│   └── utils/                    # Helper functions, formatters
│
├── domain/                       # Domain models and entities
│   ├── entities/                 # TypeORM entities
│   ├── models/                   # Domain models
│
├── modules/                      # Feature modules
│   ├── base/                     # Base module classes
│   └── [module-name]/            # Specific feature modules
│
└── templates/                    # Template files
    ├── email/                    # Email templates (EJS)
    └── pdf/                      # PDF templates
```

## Module Structure (CQRS Pattern)

Each feature module should follow this structure:

```
modules/[module-name]/
├── [module-name].module.ts       # Module definition
├── [module-name].service.ts      # Business logic service (optional)
│
├── commands/                     # Write operations (CQRS)
│   ├── handlers/
│   │   ├── create-[entity].handler.ts
│   │   ├── update-[entity].handler.ts
│   │   └── delete-[entity].handler.ts
│   └── impl/
│       ├── create-[entity].command.ts
│       ├── update-[entity].command.ts
│       └── delete-[entity].command.ts
│
├── queries/                      # Read operations (CQRS)
│   ├── handlers/
│   │   ├── get-[entity].handler.ts
│   │   └── get-[entity]-list.handler.ts
│   └── impl/
│       ├── get-[entity].query.ts
│       └── get-[entity]-list.query.ts
│
├── events/                       # Domain events
│   ├── handlers/
│   │   └── [entity]-[action].handler.ts
│   └── impl/
│       └── [entity]-[action].event.ts
│
├── dto/                          # Data Transfer Objects
│   ├── create-[entity].dto.ts
│   ├── update-[entity].dto.ts
│   └── [entity]-response.dto.ts
│
├── constants/                    # Module-specific constants
│   └── [module-name].constant.ts
│
├── [module-name].controller.ts           # Query endpoints (GET)
└── [module-name]-cmd.controller.ts       # Command endpoints (POST, PUT, DELETE)
```

## Test Structure (`test/`)

```
test/
├── test.e2e.ts                   # E2E test entry point
├── setup-app.ts                  # Test configuration and setup
│
├── factory/                      # Test data factories
│   ├── index.ts                  # Factory exports
│   ├── product.ts                # Product factory
│   ├── category.ts               # Category factory
│   ├── headers.ts                # Test request headers
│   ├── microservice-request.ts   # Microservice request factory
│   └── aws.ts                    # AWS service mocks
│
└── modules/                      # Mirror src/modules structure
    └── [module-name]/            # Module test directory
        ├── [feature-name].spec.ts        # Feature test
        ├── [another-feature].spec.ts     # Another feature test
        └── helper.ts                     # Module test helpers
```

### Test File Naming Conventions
- Feature tests: `[feature-name].spec.ts`
  - Examples: `bulk-update-product-inventory.spec.ts`
  - Examples: `get-product-inventory-list.spec.ts`
  - Examples: `inventory-changed-event.spec.ts`
- Helper utilities: `helper.ts` (per module)
- Factory files: `[resource-name].ts` in factory folder

### Test Helper Pattern
Each module has a `helper.ts` file that provides:
- Test data creation methods
- Database cleanup utilities
- Module-specific test utilities

Example:
```typescript
export class ProductInventoryHelper {
  constructor(private module: TestingModule) {}

  async createECommerceProduct() { ... }
  async clear() { ... }
}
```

## Directory Responsibilities

### `/config`
Configuration files and settings management using `@nestjs/config` ConfigModule.
- Database connections
- Redis configuration
- AWS services
- Microservice configurations

### `/common`
Framework-level utilities that are not business-specific:
- **constant**: Global constants, error codes
- **dto**: Base DTOs, pagination, common request/response types
- **services**: Logging service, HTTP client, utility services

### `/shared`
Business-specific shared code used across multiple modules:
- **enum**: Application enums (OrderStatus, PaymentMethod, etc.)
- **models**: Value objects, shared DTOs
- **utils**: Helper functions, formatters, validators

### `/domain`
Domain-driven design entities and core business models:
- **entities**: TypeORM database entities
- **models**: Domain models, value objects

### `/modules`
Feature modules implementing business capabilities. Each module should be:
- Self-contained with clear boundaries
- Follow CQRS pattern (commands/queries separation)
- Separate read (query) and write (command) controllers
- Include domain events for asynchronous processing

### `/templates`
Template files for generating dynamic content:
- **email**: Email templates using EJS
- **pdf**: PDF templates for documents (e-voucher, invoice)

### `/test`
- **factory**: Reusable test data factories
- **modules**: Integration tests mirroring src/modules structure
- **setup-app.ts**: Global test configuration

## Naming Conventions

### Files
- Use kebab-case: `product-inventory.service.ts`
- Include type suffix: `.controller.ts`, `.service.ts`, `.module.ts`, `.dto.ts`, `.entity.ts`
- Commands: `create-product.command.ts`, `create-product.handler.ts`
- Queries: `get-product.query.ts`, `get-product.handler.ts`
- Events: `product-created.event.ts`, `product-created.handler.ts`
- Test files: `[feature-name].spec.ts`, `helper.ts`

### Directories
- Use kebab-case: `product-inventory/`, `e-voucher-code/`
- Pluralize for collections: `commands/`, `queries/`, `entities/`, `dto/`

### Classes
- Use PascalCase with descriptive suffixes:
  - Controllers: `ProductInventoryController`, `ProductInventoryCmdController`
  - Services: `ProductInventoryService`
  - Modules: `ProductInventoryModule`
  - DTOs: `CreateProductDto`, `ProductResponseDto`
  - Entities: `Product`, `ProductInventory`
  - Commands: `CreateProductCommand`
  - Handlers: `CreateProductHandler`
  - Events: `ProductCreatedEvent`

## Module Organization Patterns

### Simple Module (No CQRS)
```
modules/healthz/
├── healthz.module.ts
├── healthz.controller.ts
└── healthz.service.ts
```

### Standard CQRS Module
```
modules/product-inventory/
├── product-inventory.module.ts
├── product-inventory.controller.ts          # GET endpoints
├── product-inventory-cmd.controller.ts      # POST/PUT/DELETE endpoints
├── commands/
│   ├── handlers/
│   └── impl/
├── queries/
│   ├── handlers/
│   └── impl/
└── dto/
```

### Complex Module with Events
```
modules/order/
├── order.module.ts
├── order.controller.ts
├── order-cmd.controller.ts
├── commands/
│   ├── handlers/
│   └── impl/
├── queries/
│   ├── handlers/
│   └── impl/
├── events/
│   ├── handlers/
│   └── impl/
└── dto/
```

## Controller Separation Pattern

### Query Controller (Read Operations)
- File: `[module-name].controller.ts`
- HTTP Methods: `GET`
- Purpose: Read operations, listing, searching
- Example: `ProductInventoryController`

### Command Controller (Write Operations)
- File: `[module-name]-cmd.controller.ts`
- HTTP Methods: `POST`, `PUT`, `PATCH`, `DELETE`
- Purpose: Create, update, delete operations
- Example: `ProductInventoryCmdController`

## Best Practices

1. **Module Independence**: Each module should be independently deployable and testable
2. **CQRS Separation**: Separate read (queries) and write (commands) operations
3. **Controller Separation**: Separate query and command controllers
4. **Single Responsibility**: One file, one class, one purpose
5. **DRY Principle**: Shared code goes in `/common` or `/shared`
6. **Clear Boundaries**: Domain logic in modules, framework concerns in common
7. **Consistent Structure**: All modules follow the same organizational pattern
8. **Type Safety**: Leverage TypeScript, use interfaces and types
9. **Testing**: Integration tests in test/modules mirroring src/modules

## Migration and Seed Structure

### Migrations
```
migrations/
└── [timestamp]-[description].ts
    Example: 1670000000000-CreateProductTable.ts

marketplace-migrations/
└── [timestamp]-[description].ts
    Example: 1670000000000-CreateMarketplaceTable.ts
```

### Seeds
```
seeds/
└── [timestamp]-[description].ts
    Example: 1670000000000-SeedInitialProducts.ts
```

## Example Module Implementation

### Product Inventory Module
```
modules/product-inventory/
├── product-inventory.module.ts
├── product-inventory.controller.ts
├── product-inventory-cmd.controller.ts
├── commands/
│   ├── handlers/
│   │   ├── create-inventory.handler.ts
│   │   └── bulk-update-inventory.handler.ts
│   └── impl/
│       ├── create-inventory.command.ts
│       └── bulk-update-inventory.command.ts
├── queries/
│   ├── handlers/
│   │   ├── get-product-inventory-detail.handler.ts
│   │   └── get-product-inventory-list.handler.ts
│   └── impl/
│       ├── get-product-inventory-detail.query.ts
│       └── get-product-inventory-list.query.ts
├── events/
│   ├── handlers/
│   │   └── inventory-changed.handler.ts
│   └── impl/
│       └── inventory-changed.event.ts
└── dto/
    ├── create-inventory.dto.ts
    └── inventory-response.dto.ts
```
