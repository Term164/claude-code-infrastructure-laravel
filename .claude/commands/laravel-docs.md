# Laravel Development Documentation

This command helps you plan and create comprehensive Laravel development documentation. It analyzes your Laravel application structure and generates technical documentation for your team.

## Usage

```bash
/laravel-docs Describe what you need documented (e.g., "API authentication system", "E-commerce checkout flow")
```

## What It Does

1. **Analyze Laravel Structure**: Examines your Laravel application's architecture including:
   - Routes and controllers
   - Models and relationships
   - Services and repositories
   - Middleware and policies
   - Database migrations and schema

2. **Generate Technical Docs**: Creates comprehensive documentation covering:
   - API endpoint documentation
   - Database schema documentation
   - Authentication and authorization flows
   - Service architecture documentation
   - Deployment and configuration guides

3. **Create Visual Diagrams**: Generates:
   - Request flow diagrams
   - Database relationship diagrams
   - Service interaction maps
   - Authentication flow charts

## Documentation Types Generated

### API Documentation
- Endpoint definitions with HTTP methods
- Request/response examples
- Authentication requirements
- Rate limiting information
- Error response formats

### Database Documentation
- Table schemas with relationships
- Migration history
- Seed data descriptions
- Index and constraint information

### Architecture Documentation
- Service layer descriptions
- Dependency injection patterns
- Middleware stack documentation
- Event system usage

### Development Setup
- Environment configuration
- Installation procedures
- Testing strategies
- Deployment processes

## Examples

### Document API System
```bash
/laravel-docs Document the complete API authentication and authorization system including Sanctum tokens, middleware, and policies
```

### Document E-commerce Flow
```bash
/laravel-docs Create documentation for the e-commerce checkout process including cart management, payment processing, and order fulfillment
```

### Document Database Schema
```bash
/laravel-docs Generate comprehensive database schema documentation with all relationships, indexes, and constraints
```

## Output Format

The command generates documentation in `dev/laravel-docs/` with the following structure:

```
dev/laravel-docs/
├── api/
│   ├── authentication.md
│   ├── endpoints.md
│   └── examples.md
├── database/
│   ├── schema.md
│   ├── relationships.md
│   └── migrations.md
├── architecture/
│   ├── services.md
│   ├── middleware.md
│   └── patterns.md
└── deployment/
    ├── setup.md
    └── configuration.md
```

## Laravel-Specific Features

### Model Relationship Mapping
- Automatically discovers Eloquent relationships
- Documents relationship types and constraints
- Provides query examples for each relationship

### Route Analysis
- Uses `php artisan route:list` for accurate route documentation
- Identifies middleware and their purposes
- Documents parameter validation and type hints

### Middleware Documentation
- Explains custom middleware implementations
- Documents middleware order and dependencies
- Provides configuration examples

### Service Container Documentation
- Maps service provider bindings
- Documents dependency injection patterns
- Explains custom service implementations

## Integration with Laravel Tools

This command integrates with:
- **Laravel Telescope**: For performance and request documentation
- **Laravel Sanctum**: For API authentication docs
- **Laravel Horizon**: For queue system documentation
- **Laravel Dusk**: For browser testing documentation

## Customization Options

The documentation can be customized based on:
- Application type (API, web, hybrid)
- Authentication method (Sanctum, Passport, custom)
- Database connections (MySQL, PostgreSQL, etc.)
- Deployment environment (local, staging, production)

Perfect for Laravel teams that need comprehensive, up-to-date technical documentation!