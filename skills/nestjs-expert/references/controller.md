# Controllers & Routing

## Controller with Swagger

```typescript
import {
  Controller, Get, Post, Patch, Delete,
  Body, Param, Query, HttpCode, HttpStatus, UseGuards
} from '@nestjs/common';
import { CommandBus, QueryBus } from '@nestjs/cqrs';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery } from '@nestjs/swagger';
import { ParseUUIDPipe, ParseIntPipe } from '@nestjs/common';

@Controller('users')
@ApiTags('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(
    private readonly commandBus: CommandBus,
    private readonly queryBus: QueryBus,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Create user' })
  @ApiResponse({ status: 201, type: UserResponseDto })
  @ApiResponse({ status: 400, description: 'Validation failed' })
  create(@Body() dto: CreateUserDto): Promise<UserResponseDto> {
    return this.commandBus.execute(new CreateUserCommand(dto));
  }

  @Get()
  @ApiOperation({ summary: 'Get all users' })
  findAll(
    @Query() query: UserListQueryDto,
  ): Promise<UserListResponseDto> {
    return this.queryBus.execute(new FindAllUsersQuery(query));
  }

  @Get(':id')
  @ApiParam({ name: 'id', type: 'string', format: 'uuid' })
  @ApiResponse({ status: 200, type: UserResponseDto })
  @ApiResponse({ status: 404, description: 'User not found' })
  findOne(@Param('id', ParseUUIDPipe) id: string): Promise<UserResponseDto> {
    return this.queryBus.execute(new FindUserQuery(id));
  }

  @Patch(':id')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateUserDto,
  ): Promise<UserResponseDto> {
    return this.commandBus.execute(new UpdateUserCommand(id, dto));
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.usersService.remove(id);
  }
}
```

## Nested Routes

```typescript
@Controller('posts/:postId/comments')
@ApiTags('comments')
export class CommentsController {
  @Get()
  findAll(@Param('postId', ParseUUIDPipe) postId: string) {
    return this.queryBus.execute(new FindAllCommentsQuery(postId));
  }

  @Post()
  create(
    @Param('postId', ParseUUIDPipe) postId: string,
    @Body() dto: CreateCommentDto,
  ) {
    return this.commandBus.execute(new CreateCommentCommand(postId, dto));
  }
}
```

## Quick Reference

| Decorator | Purpose |
|-----------|---------|
| `@Controller('path')` | Define route prefix |
| `@Get()`, `@Post()` | HTTP method |
| `@Param('name')` | Path parameter |
| `@Query('name')` | Query parameter |
| `@Body()` | Request body |
| `@HttpCode(201)` | Override status code |
| `@ApiTags()` | Swagger grouping |
| `@ApiOperation()` | Endpoint description |
| `@ApiResponse()` | Document response |