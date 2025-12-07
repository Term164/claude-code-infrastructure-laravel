---
name: laravel-dev-guidelines
description: Comprehensive Laravel development guide for PHP/Laravel applications. Use when creating routes, controllers, services, repositories, middleware, or working with Laravel APIs, Eloquent database access, Sentry error tracking, form request validation, Laravel config, dependency injection, or service container patterns. Covers layered architecture (routes → controllers → services → repositories), BaseController pattern, error handling, performance monitoring, testing strategies, and migration from legacy patterns.
---

# Laravel Development Guidelines

## Purpose

Establish consistency and best practices across Laravel applications using modern PHP/Laravel patterns with proper MVC architecture, Eloquent ORM, and Laravel's built-in features.

## When to Use This Skill

Automatically activates when working on:
- Creating or modifying routes, endpoints, APIs
- Building controllers, services, repositories
- Implementing middleware (auth, validation, error handling)
- Database operations with Eloquent
- Error tracking with Sentry
- Input validation with Form Requests
- Configuration management
- Backend testing and refactoring

---

## Quick Start

### New Laravel Feature Checklist

- [ ] **Route**: Clean definition in routes/api.php or routes/web.php
- [ ] **Controller**: Extend BaseController with proper response handling
- [ ] **Service**: Business logic with dependency injection
- [ ] **Repository**: Database access layer (if complex)
- [ ] **Validation**: Form Request class
- [ ] **Sentry**: Error tracking integration
- [ ] **Tests**: Feature and unit tests
- [ ] **Config**: Use Laravel config system

### New Laravel Application Checklist

- [ ] Directory structure (see [architecture-overview.md](architecture-overview.md))
- [ ] Sentry configuration in config/sentry.php
- [ ] BaseController setup
- [ ] Middleware stack configuration
- [ ] Exception handler customization
- [ ] Testing framework setup

---

## Architecture Overview

### Layered Architecture

```
HTTP Request
    ↓
Routes (routing only - routes/api.php, routes/web.php)
    ↓
Controllers (request handling - app/Http/Controllers/)
    ↓
Services (business logic - app/Services/)
    ↓
Repositories (data access - app/Repositories/)
    ↓
Database (Eloquent ORM)
```

**Key Principle:** Each layer has ONE responsibility.

See [architecture-overview.md](architecture-overview.md) for complete details.

---

## Directory Structure

```
laravel-app/
├── app/
│   ├── Http/
│   │   ├── Controllers/         # Controllers
│   │   ├── Middleware/          # Laravel middleware
│   │   └── Requests/            # Form Requests
│   ├── Services/                # Business logic
│   ├── Repositories/            # Data access
│   ├── Models/                  # Eloquent models
│   ├── Providers/               # Service providers
│   └── Exceptions/              # Custom exceptions
├── config/                      # Laravel configuration
├── database/
│   ├── migrations/              # Database migrations
│   └── seeders/                 # Database seeders
├── routes/
│   ├── api.php                  # API routes
│   ├── web.php                  # Web routes
│   └── console.php              # Console routes
├── tests/
│   ├── Feature/                 # Feature tests
│   └── Unit/                    # Unit tests
└── bootstrap/                   # Bootstrap files
```

**Naming Conventions:**
- Controllers: `PascalCase` - `UserController.php`
- Services: `PascalCase` - `UserService.php`
- Models: `PascalCase` - `User.php`
- Repositories: `PascalCase` - `UserRepository.php`
- Form Requests: `PascalCase` - `StoreUserRequest.php`

---

## Core Principles (7 Key Rules)

### 1. Routes Only Route, Controllers Control

```php
// ❌ NEVER: Business logic in routes
Route::post('/users', function (Request $request) {
    // 200 lines of logic
});

// ✅ ALWAYS: Delegate to controller
Route::post('/users', [UserController::class, 'store']);
```

### 2. All Controllers Extend BaseController

```php
class UserController extends BaseController
{
    public function show(User $user): JsonResponse
    {
        try {
            return $this->successResponse($user);
        } catch (Exception $e) {
            return $this->errorResponse($e, 'user.show');
        }
    }
}
```

### 3. All Errors to Sentry

```php
try {
    $result = $this->service->process($data);
} catch (Exception $e) {
    Sentry::captureException($e);
    throw $e;
}
```

### 4. Use Laravel Config, NEVER env() Directly

```php
// ❌ NEVER
$timeout = env('TIMEOUT_MS');

// ✅ ALWAYS
$timeout = config('app.timeout');
```

### 5. Validate All Input with Form Requests

```php
public function store(StoreUserRequest $request): JsonResponse
{
    $validated = $request->validated();
    // $validated is already validated
}
```

### 6. Use Repository Pattern for Complex Data Access

```php
// Service → Repository → Database
$users = $userRepository->findActive();
```

### 7. Comprehensive Testing Required

```php
class UserServiceTest extends TestCase
{
    public function test_it_creates_user(): void
    {
        $user = $this->userService->create($userData);
        $this->assertInstanceOf(User::class, $user);
    }
}
```

---

## Common Imports

```php
// Laravel Core
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\DB;

// Database
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;

// Auth
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Gate;

// Validation
use Illuminate\Validation\Rule;

// Sentry
use Sentry\State\Scope;
use function Sentry\captureException;
use function Sentry\configureScope;

// Exceptions
use Illuminate\Validation\ValidationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
```

---

## Quick Reference

### HTTP Status Codes

| Code | Use Case | Laravel Method |
|------|----------|----------------|
| 200 | Success | `response()->json()` |
| 201 | Created | `response()->json()` + status 201 |
| 400 | Bad Request | `response()->json()` + status 400 |
| 401 | Unauthorized | `response()->json()` + status 401 |
| 403 | Forbidden | `response()->json()` + status 403 |
| 404 | Not Found | `response()->json()` + status 404 |
| 422 | Validation Error | `response()->json()` + status 422 |
| 500 | Server Error | `response()->json()` + status 500 |

### Service Templates

**E-commerce App** (✅ Mature) - Use as template for REST APIs
**SaaS Platform** (✅ Mature) - Use as template for authentication patterns

---

## Anti-Patterns to Avoid

❌ Business logic in routes files
❌ Direct env() usage outside config files
❌ Missing error handling
❌ No input validation
❌ Raw SQL queries everywhere (use Eloquent)
❌ dd() or die() in production code

---

## Navigation Guide

| Need to... | Read this |
|------------|-----------|
| Understand architecture | [architecture-overview.md](architecture-overview.md) |
| Create routes/controllers | [routing-and-controllers.md](routing-and-controllers.md) |
| Organize business logic | [services-and-repositories.md](services-and-repositories.md) |
| Validate input | [validation-patterns.md](validation-patterns.md) |
| Add error tracking | [sentry-and-monitoring.md](sentry-and-monitoring.md) |
| Create middleware | [middleware-guide.md](middleware-guide.md) |
| Database access | [database-patterns.md](database-patterns.md) |
| Manage config | [configuration.md](configuration.md) |
| Handle async/errors | [async-and-errors.md](async-and-errors.md) |
| Write tests | [testing-guide.md](testing-guide.md) |
| See examples | [complete-examples.md](complete-examples.md) |

---

## Resource Files

### [architecture-overview.md](architecture-overview.md)
Layered architecture, request lifecycle, separation of concerns

### [routing-and-controllers.md](routing-and-controllers.md)
Route definitions, BaseController, error handling, examples

### [services-and-repositories.md](services-and-repositories.md)
Service patterns, DI, repository pattern, caching

### [validation-patterns.md](validation-patterns.md)
Form Requests, validation rules, DTO pattern

### [sentry-and-monitoring.md](sentry-and-monitoring.md)
Sentry integration, error capture, performance monitoring

### [middleware-guide.md](middleware-guide.md)
Auth, rate limiting, error boundaries, request context

### [database-patterns.md](database-patterns.md)
Eloquent models, repositories, transactions, optimization

### [configuration.md](configuration.md)
Laravel config, environment files, secrets

### [async-and-errors.md](async-and-errors.md)
Queue jobs, custom exceptions, error handling

### [testing-guide.md](testing-guide.md)
Feature/unit tests, mocking, coverage

### [complete-examples.md](complete-examples.md)
Full examples, refactoring guide

---

## Related Skills

- **database-verification** - Verify column names and schema consistency
- **error-tracking** - Sentry integration patterns
- **skill-developer** - Meta-skill for creating and managing skills

---

**Skill Status**: COMPLETE ✅
**Line Count**: < 500 ✅
**Progressive Disclosure**: 11 resource files ✅