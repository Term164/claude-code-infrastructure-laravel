# Laravel Route Research for Testing

This command helps you map Laravel route definitions and launches testing for API endpoints or web routes. It analyzes your Laravel application's routing structure and provides testing strategies.

## Usage

```bash
/laravel-route-research [optional-path-override]
```

## What It Does

1. **Route Discovery**: Scans your Laravel route files (`routes/web.php`, `routes/api.php`, etc.) to identify all registered routes
2. **Route Analysis**: Maps controllers, middleware, and route parameters
3. **Test Strategy**: Generates testing approaches for different route types
4. **Laravel Integration**: Provides Artisan commands and testing patterns specific to Laravel

## Key Features

### Route File Analysis
- Scans all Laravel route files in the `routes/` directory
- Identifies API routes (`routes/api.php`) vs web routes (`routes/web.php`)
- Maps route groups and middleware
- Detects route model binding patterns

### Controller Mapping
- Links routes to their corresponding controllers
- Identifies controller methods and parameter requirements
- Maps form request validation classes
- Checks authorization requirements

### Test Generation
- Generates Pest/PHPUnit test files for routes
- Creates feature tests for API endpoints
- Provides browser testing setup for web routes
- Includes authentication testing strategies

## Examples

### Basic Usage
```bash
/laravel-route-research
```

### Specific Route Group
```bash
/laravel-route-research api/v1
```

## Output Format

The command provides:
1. **Route Summary**: Total routes by type and method
2. **Controller Map**: Which controllers handle which routes
3. **Test Plan**: Specific testing recommendations
4. **Authentication Requirements**: Which routes need auth tokens
5. **Parameter Documentation**: Required route parameters and validation

## Laravel-Specific Features

- **Artisan Integration**: Uses `php artisan route:list` for accurate route discovery
- **Middleware Analysis**: Identifies authentication, CORS, and rate limiting middleware
- **Resource Routes**: Special handling for Laravel resource routes
- **Form Request Detection**: Identifies validation classes for each route
- **Policy Checking**: Checks authorization policies for protected routes

## Testing Strategies Provided

### API Routes
- Pest/PHPUnit feature tests
- Postman collection generation
- Authentication token setup
- Rate limiting testing

### Web Routes
- Browser tests with Dusk/Laravel Browser Kit
- Form submission testing
- Session management testing
- CSRF token handling

### Special Cases
- File upload routes
- Route model binding
- Custom middleware
- API versioning routes

## Integration with Existing Tools

This command works seamlessly with:
- Laravel Telescope for route monitoring
- Laravel Horizon for queue route testing
- Sanctum/PASSPORT for API authentication
- Laravel Dusk for browser testing

Perfect for Laravel developers who want comprehensive route testing and documentation!