# Laravel Architecture Overview

## Layered Architecture in Laravel

### Request Flow

```
HTTP Request
    ↓
Router (routes/api.php, routes/web.php)
    ↓
Middleware Stack
    ↓
Controller (app/Http/Controllers/)
    ↓
Service (app/Services/)
    ↓
Repository (app/Repositories/)
    ↓
Model (app/Models/)
    ↓
Database (MySQL/PostgreSQL/etc.)
```

### Separation of Concerns

Each layer has a single responsibility:

1. **Routes**: URL → Controller mapping only
2. **Controllers**: HTTP request/response handling
3. **Services**: Business logic and orchestration
4. **Repositories**: Data access abstraction
5. **Models**: Database representation and relationships
6. **Database**: Data persistence

---

## Directory Structure Deep Dive

```
laravel-app/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── BaseController.php      # Base controller with common methods
│   │   │   ├── UserController.php      # User-related endpoints
│   │   │   └── Api/
│   │   │       └── v1/                 # API versioning
│   │   ├── Middleware/
│   │   │   ├── Authenticate.php        # Authentication
│   │   │   └── LogRequest.php          # Request logging
│   │   └── Requests/
│   │       ├── StoreUserRequest.php    # User creation validation
│   │       └── UpdateUserRequest.php   # User update validation
│   ├── Services/
│   │   ├── UserService.php             # User business logic
│   │   ├── PaymentService.php          # Payment processing
│   │   └── Contracts/                  # Service interfaces
│   │       └── UserServiceInterface.php
│   ├── Repositories/
│   │   ├── UserRepository.php          # User data access
│   │   └── Contracts/
│   │       └── UserRepositoryInterface.php
│   ├── Models/
│   │   ├── User.php                    # User model
│   │   ├── Post.php                    # Post model
│   │   └── Traits/
│   │       ├── HasUuid.php             # Reusable model traits
│   │       └── SoftDeletes.php
│   ├── Providers/
│   │   ├── AppServiceProvider.php      # App-level bindings
│   │   └── RepositoryServiceProvider.php # Repository bindings
│   └── Exceptions/
│       ├── Handler.php                 # Global exception handler
│       └── Custom/
│           ├── UserNotFoundException.php
│           └── InsufficientBalanceException.php
├── config/
│   ├── sentry.php                      # Sentry configuration
│   ├── services.php                    # External service config
│   └── repository.php                  # Repository settings
├── database/
│   ├── migrations/
│   │   ├── 2024_01_01_create_users_table.php
│   │   └── 2024_01_02_create_posts_table.php
│   └── seeders/
│       └── UserSeeder.php
└── tests/
    ├── Feature/
    │   ├── UserTest.php                # User feature tests
    │   └── AuthTest.php                # Authentication tests
    └── Unit/
        ├── UserServiceTest.php         # Service unit tests
        └── UserRepositoryTest.php      # Repository unit tests
```

---

## The Laravel Container (IoC)

### Service Container Usage

```php
// Register in service provider
$this->app->bind(UserRepositoryInterface::class, UserRepository::class);
$this->app->bind(UserServiceInterface::class, UserService::class);

// Automatic injection in controller
public function __construct(
    private UserServiceInterface $userService
) {}

// Manual resolution
$service = app(UserServiceInterface::class);
```

### Service Providers

**AppServiceProvider**:
- General application bindings
- View composers
- Shared view data

**RepositoryServiceProvider**:
- Interface to implementation bindings
- Repository-specific configuration

---

## Request Lifecycle

1. **Entry Point**: `public/index.php`
2. **Kernel Loading**: HTTP/Console Kernel initialization
3. **Router**: Route definition matching
4. **Middleware**: Authentication, CORS, rate limiting
5. **Controller**: Request handling
6. **Service**: Business logic execution
7. **Response**: JSON/HTML response formation
8. **Middleware (post)**: Response modification
9. **Output**: Response sent to client

---

## Data Flow Examples

### API Endpoint Example

```php
// routes/api.php
Route::apiResource('users', UserController::class);

// app/Http/Controllers/UserController.php
class UserController extends BaseController
{
    public function __construct(
        private UserServiceInterface $userService
    ) {}

    public function index(IndexUserRequest $request): JsonResponse
    {
        $users = $this->userService->getPaginatedUsers(
            $request->validated(),
            $request->per_page ?? 15
        );

        return $this->successResponse($users);
    }
}

// app/Services/UserService.php
class UserService implements UserServiceInterface
{
    public function __construct(
        private UserRepositoryInterface $userRepository,
        private CacheService $cacheService
    ) {}

    public function getPaginatedUsers(array $filters, int $perPage): LengthAwarePaginator
    {
        $cacheKey = "users.{$perPage}." . md5(serialize($filters));

        return $this->cacheService->remember($cacheKey, 300, function() use ($filters, $perPage) {
            return $this->userRepository->paginateWithFilters($filters, $perPage);
        });
    }
}

// app/Repositories/UserRepository.php
class UserRepository implements UserRepositoryInterface
{
    public function paginateWithFilters(array $filters, int $perPage): LengthAwarePaginator
    {
        return User::query()
            ->when(isset($filters['search']), function (Builder $query) use ($filters) {
                $query->where('name', 'like', "%{$filters['search']}%");
            })
            ->when(isset($filters['status']), function (Builder $query) use ($filters) {
                $query->where('status', $filters['status']);
            })
            ->paginate($perPage);
    }
}
```

---

## Key Laravel Concepts

### Eloquent ORM

- **Models**: Database table representation
- **Relationships**: Database relationships as methods
- **Scopes**: Queryable model filters
- **Accessors/Mutators**: Attribute manipulation
- **Observers**: Model event handling

### Middleware

- **Global**: Applied to all routes
- **Route**: Applied to specific routes/groups
- **Terminal**: Run after response sent

### Form Requests

- **Authorization**: User permissions check
- **Validation**: Input validation rules
- **Preparation**: Input modification before validation

### Queues & Jobs

- **Async Processing**: Background task execution
- **Job Classes**: Encapsulated business logic
- **Failed Jobs**: Error handling and retries

---

## Best Practices

### Single Responsibility Principle
- Controllers handle HTTP concerns only
- Services contain business logic only
- Repositories handle data access only

### Dependency Injection
- Inject dependencies via constructor
- Use interfaces for loose coupling
- Let Laravel's container resolve dependencies

### Configuration Management
- Store config in `config/` directory
- Use `config()` helper, never `env()` directly
- Environment-specific config in `.env`

### Error Handling
- Use exceptions for expected errors
- Custom exceptions for domain-specific errors
- Global handler for consistent error responses

### Security
- Validate all input
- Use mass assignment protection
- Implement proper authorization
- Sanitize output