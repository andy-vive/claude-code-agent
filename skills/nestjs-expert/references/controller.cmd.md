# CMD Controller

## Controller definition

```typescript
import { Controller, UseInterceptors, UseFilters } from '@nestjs/common';
import { CommandBus, QueryBus } from '@nestjs/cqrs';

@Controller()
export class UserCmdController {
  constructor(
    private readonly commandBus: CommandBus,
    private readonly queryBus: QueryBus,
  ) {}

  @MessagePattern(USER_PATTERNS.user.create)
  async createUser(
    request: MicroserviceRequest<CreateUserRequestDto>,
  ): Promise<UserResponseDto> {
    return this.commandBus.execute(new CreateUserCommand(request.input));
  }

  @MessagePattern(USER_PATTERNS.user.getDetail)
  async getUserDetail(
    request: MicroserviceRequest<string>,
  ): Promise<UserResponseDto> {
    const userId = request.input;
    return this.queryBus.execute(new GetUserDetailQuery(userId));
  }
}

```