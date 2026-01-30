# Testing

## Generated Files Structure

### For API
For `User` entity with list API:

```
test/modules/user/
├── get-user-list.spec.ts              
├── helper.ts                          
└── factory/
    └── user.factory.ts                
```

## Test File Structures

### API Test

```typescript
import request from 'supertest';
import { INestApplication } from '@nestjs/common';
import { UserHelper } from './helper';

describe('Get list user (e2e)', () => {
  let app: INestApplication;
  let helper: UserHelper;

  beforeAll(async () => {
    app = global.testContext.app;
    helper = new UserHelper(global.testContext.module);
  });

  beforeEach(async () => {
  });

  afterEach(async () => {
    await helper.clear();
  });

  describe('GET /users - Get list user', () => {
    beforeEach(async () => {
    });

    afterEach(() => {
      jest.clearAllMocks();
    });

    it('should successfully get list user', async () => {
      const users = await Promise.all([
        helper.createTestUser({
          email: 'test@example.com',
          isActive: true,
        }),
        helper.createTestUser({
          email: 'test2@example.com',
          isActive: true,
        }),
      ])

      const response = await request(app.getHttpServer())
        .get('/users')
        .set('Authorization', 'Bearer mock-token')
        .expect(200);

      expect(response.body.data.length).toBe(users.length);
    });
  });
});

```

## Test Scenarios

### Standard Test Scenarios (Auto-generated based on API type)

#### List API Scenarios
- **Basic Success**: Returns data successfully
- **Empty Results**: Handles empty result sets
- **Pagination**: Tests offset, limit, and total count
- **Sorting**: Tests all available sort options
- **Filtering**: Tests each filter parameter
- **Search**: Tests text search functionality (if applicable)
- **Validation**: Tests input validation for all parameters
- **Error Handling**: Tests database errors and edge cases

#### Detail API Scenarios
- **Basic Success**: Returns single entity successfully
- **Not Found**: Returns 404 for non-existent entities
- **Relationships**: Tests included related entities
- **Validation**: Tests UUID validation for ID parameter
- **Error Handling**: Tests various error conditions

#### Create API Scenarios
- **Basic Success**: Creates entity successfully
- **Validation**: Tests input validation for all parameters
- **Error Handling**: Tests database errors and edge cases

#### Update API Scenarios
- **Basic Success**: Updates entity successfully
- **Not Found**: Returns 404 for non-existent entities
- **Validation**: Tests input validation for all parameters
- **Error Handling**: Tests database errors and edge cases

#### Delete API Scenarios
- **Basic Success**: Deletes entity successfully
- **Not Found**: Returns 404 for non-existent entities
- **Error Handling**: Tests various error conditions

## Service Mocking Patterns


**Rule**: Mock all external services, keep only database operations real.

#### Service-Specific Mocking
```typescript
// Mock specific service methods
jest
  .spyOn(externalService, 'createExternalUser')
  .mockImplementationOnce((): Promise => {
    return Promise.resolve({
      data: {
        id: '1',
        email: 'test@example.com',
        name: 'test',
        role: 'test',
        businessId: 1,
      },
    });
  });
```

#### Mock Reset Pattern
```typescript
afterEach(async () => {
  jest.resetAllMocks(); // Reset all mocks after each test
  await entityHelper.clearData();
});
```

#### Error Simulation Mocking
```typescript
it('should handle service failures gracefully', async () => {
  jest.resetAllMocks();
  jest
    .spyOn(externalService, 'createExternalUser')
    .mockRejectedValueOnce(new Error('External service unavailable'));
});
```

#### Service Dependencies Testing
```typescript
describe('Service Integration', () => {
  it('should call external service with correct parameters', async () => {
    const externalSpy = jest.spyOn(externalService, 'createExternalUser')
      .mockImplementation(() => Promise.resolve({ data: fakeExternalUserData }));

    await request(server)
      .post('/users')
      .set('Authorization', 'Bearer mock-token')
      .send({
        email: 'test@example.com',
        name: 'test',
        role: 'test',
        businessId: 1,
      })

    expect(externalSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        cmd: 'createExternalUser',
        data: expect.objectContaining({
          email: 'test@example.com',
          name: 'test',
          role: 'test',
          businessId: 1,
        })
      })
    );
  });
});
```

## Mock Data Factory (`{entity}.factory.ts`)

```typescript
import { User } from '@prisma/client';
import { v4 as uuidv4 } from 'uuid';

export const createUser = (overrides?: any) => {
  const userId = overrides?.userId || uuidv4();

  return {
    userId,
    email: overrides?.email || 'test@example.com',
    name: overrides?.name || 'Test User',
    role: overrides?.role || 'test',
    businessId: overrides?.businessId || 1,
    isActive: overrides?.isActive !== undefined ? overrides.isActive : true,
    ...overrides,
  };
};
```

## Helper Functions (`helper.ts`)

```typescript
import { TestingModule } from '@nestjs/testing';
import { PrismaService } from 'src/modules/prisma/prisma.service';
import {
  createTestUser,
} from '../../factory';

export class UserHelper {
  public readonly prisma: PrismaService;

  constructor(module: TestingModule) {
    this.prisma = module.get(PrismaService);
  }

  async createTestUser(overrides?: any) {
    const userData = createTestUser(overrides);
    return this.prisma.user.create({
      data: userData as any,
    });
  }

  async createTestUser(overrides?: any) {
    const userData = createTestUser(overrides);
    return this.prisma.user.create({
      data: userData as any,
    });
  }
  
  async clear() {
    // Clean up in correct order due to foreign key constraints
    await this.prisma.user.deleteMany({});
  }
}
```

## Test Data Patterns

### Realistic Test Data
- Use faker.js for generating realistic data
- Follow entity validation rules
- Include edge cases (empty strings, null values, etc.)
- Test with various data types and formats

### Relationship Testing
- Test APIs with and without related entities
- Verify correct relationship loading
- Test relationship filtering and sorting

### Permission Testing
- Test different user roles and permissions
- Verify organization-scoped access
- Test cross-tenant data isolation
