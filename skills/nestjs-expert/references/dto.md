# DTO definition

## Request DTO
```typescript
export class CreateUserRequestDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsNotEmpty()
  email: string;

  @IsString()
  @IsNotEmpty()
  password: string;
}
```

## Response DTO
```typescript
export class UserResponseDto {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
  updatedAt: Date;
}
```