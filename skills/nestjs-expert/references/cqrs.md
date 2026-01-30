# CQRS

## Setup

Install `@nestjs/cqrs` package.
```bash
yarn add @nestjs/cqrs
```

Import CqrsModule in feature module:
```typescript
import { CqrsModule } from '@nestjs/cqrs';

@Module({
  imports: [CqrsModule],
  providers: [
    ...CommandHandlers,
    ...QueryHandlers,
    ...EventHandlers,
  ],
})
export class FeatureModule {}
```

## Command

### Create command class:

```typescript
import { CommandHandler, ICommandHandler } from "@nestjs/cqrs";
import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { EventBus } from "@nestjs/cqrs";
import { Repository } from "typeorm";
import { plainToInstance } from "class-transformer";
import { UserCreatedEvent } from "../events";
import { UserResponseDto, CreateUserRequestDto } from "../dtos";

export class CreateUserCommand {
  constructor(public readonly dto: CreateUserRequestDto) {}
}

@Injectable()
export class CreateUserCommandHandler implements ICommandHandler<CreateUserCommand> {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private eventBus: EventBus,
  ) {}

  async execute(command: CreateUserCommand): Promise<UserResponseDto> {
    const user = await this.userRepository.save(command.dto);

    // Publish domain event
    this.eventBus.publish(new UserCreatedEvent(user));

    return plainToInstance(UserResponseDto, user);
  }
}
```

### Create command with Prisma

```typescript
import { CommandHandler, ICommandHandler } from "@nestjs/cqrs";
import { Injectable } from "@nestjs/common";
import { EventBus } from "@nestjs/cqrs";
import { plainToInstance } from "class-transformer";
import { UserCreatedEvent } from "../events";
import { UserResponseDto, CreateUserRequestDto } from "../dtos";
import { PrismaService } from "../../prisma";

export class CreateUserCommand {
  constructor(public readonly dto: CreateUserRequestDto) {}
}

@Injectable()
export class CreateUserCommandHandler implements ICommandHandler<CreateUserCommand> {
  constructor(
    private prisma: PrismaService,
    private eventBus: EventBus,
  ) {}

  async execute(command: CreateUserCommand): Promise<UserResponseDto> {
    const user = await this.prisma.user.create({
      data: command.dto,
    });

    // Publish domain event
    this.eventBus.publish(new UserCreatedEvent(user));

    return plainToInstance(UserResponseDto, user);
  }
}
```

### Export command handler in index.ts

```typescript
import { CreateUserCommandHandler } from './create-user.command';

export * from './create-user.command';

export const CommandHandlers = [CreateUserCommandHandler];

```

## Query

### Create query class:
```typescript
import { QueryHandler, IQueryHandler } from "@nestjs/cqrs";

export class FindUserQuery {
  constructor(public readonly id: string) {}
}

@Injectable()
export class FindUserQueryHandler implements IQueryHandler<FindUserQuery> {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async execute(query: FindUserQuery): Promise<UserResponseDto> {
    const user = await this.userRepository.findOne(query.id);
    return plainToInstance(UserResponseDto, user);
  }
}
```

### Create query with Prisma
```typescript
import { QueryHandler, IQueryHandler } from "@nestjs/cqrs";

export class FindUserQuery {
  constructor(public readonly id: string) {}
}

@Injectable()
export class FindUserQueryHandler implements IQueryHandler<FindUserQuery> {
  constructor(
    private prisma: PrismaService,
  ) {}

  async execute(query: FindUserQuery): Promise<UserResponseDto> {
    const user = await this.prisma.user.findUnique({
      where: { id: query.id },
    });
    return plainToInstance(UserResponseDto, user);
  }
}
```

### Export query handler in index.ts
```typescript
import { FindUserQueryHandler } from './find-user.query';

export * from './find-user.query';

export const QueryHandlers = [FindUserQueryHandler];
```

## Event

```typescript
export class UserCreatedEvent {
  constructor(public readonly user: UserResponseDto) {}
}

@Injectable()
export class UserCreatedEventHandler implements IEventHandler<UserCreatedEvent> {
  constructor(private emailService: EmailService) {}

  async handle(event: UserCreatedEvent): Promise<void> {
    await this.emailService.sendWelcomeEmail(event.user);
  }
}
```

## Quick Reference

| Decorator | Purpose |
|-----------|---------|
| `@CommandHandler()` | Command handler |
| `@QueryHandler()` | Query handler |
| `@EventHandler()` | Event handler |
