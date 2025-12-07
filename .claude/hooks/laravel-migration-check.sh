#!/bin/bash

# Laravel Migration Check Hook
# Runs on stop to check migration status and suggest actions

# Check if we're in a Laravel project
if [ ! -f "artisan" ]; then
    exit 0
fi

echo ""
echo "🗄️ Laravel Migration Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if database is configured
if [ ! -f ".env" ]; then
    echo "❓ .env file not found"
    echo "   → Run: cp .env.example .env"
    echo "   → Then: php artisan key:generate"
    echo ""
    exit 0
fi

# Check if vendor directory exists
if [ ! -d "vendor" ]; then
    echo "❓ Laravel vendor directory missing"
    echo "   → Run: composer install"
    echo ""
    exit 0
fi

# Check migration status
echo "Checking migration status..."

# Try to get migration status (suppress errors if database not configured)
MIGRATION_OUTPUT=$(php artisan migrate:status 2>/dev/null)
MIGRATION_EXIT_CODE=$?

if [ $MIGRATION_EXIT_CODE -ne 0 ]; then
    echo "❌ Cannot check migration status"
    echo "   → Possible issues:"
    echo "     • Database not configured"
    echo "     • Database connection failed"
    echo "     • Database doesn't exist"
    echo ""
    echo "   → Check your .env database configuration"
    echo "   → Run: php artisan config:cache"
    exit 0
fi

# Parse migration output
PENDING_COUNT=$(echo "$MIGRATION_OUTPUT" | grep -c "Pending" || echo "0")
RAN_COUNT=$(echo "$MIGRATION_OUTPUT" | grep -c "Ran" || echo "0")

if [ "$PENDING_COUNT" -gt 0 ]; then
    echo "⚠️  $PENDING_COUNT pending migration(s)"
    echo ""

    # Show which migrations are pending
    echo "Pending migrations:"
    echo "$MIGRATION_OUTPUT" | grep "Pending" | head -5 | while read line; do
        migration_name=$(echo "$line" | awk '{print $2}')
        echo "   → $migration_name"
    done

    if [ "$PENDING_COUNT" -gt 5 ]; then
        echo "   → ... and $((PENDING_COUNT - 5)) more"
    fi

    echo ""
    echo "📋 Suggested actions:"
    echo "   → Review pending migrations: php artisan migrate:status"
    echo "   → Run migrations: php artisan migrate"
    echo "   → Run with force (production): php artisan migrate --force"
    echo ""
    echo "⚠️  WARNING: Always backup production database before migrating!"

elif [ "$RAN_COUNT" -gt 0 ]; then
    echo "✅ All $RAN_COUNT migration(s) have been run"
    echo "   Database is up to date"
else
    echo "ℹ️  No migrations found"
    echo "   → Create your first migration: php artisan make:migration create_users_table"
fi

# Check for fresh migration opportunities
echo ""
echo "🔧 Migration Environment Check:"

# Check database connection
if php artisan db:show >/dev/null 2>&1; then
    echo "   ✅ Database connection successful"
else
    echo "   ❓ Database connection issues detected"
fi

# Check if migrations table exists
MIGRATIONS_TABLE_EXISTS=$(php artisan tinker --execute="echo Schema::hasTable('migrations') ? 'yes' : 'no';" 2>/dev/null)
if [ "$MIGRATIONS_TABLE_EXISTS" = "yes" ]; then
    echo "   ✅ Migrations table exists"
else
    echo "   ❓ Migrations table not found (will be created on first migrate)"
fi

# Check for common migration files
if [ -d "database/migrations" ]; then
    MIGRATION_COUNT=$(find database/migrations -name "*.php" | wc -l)
    echo "   ✅ $MIGRATION_COUNT migration file(s) found"
else
    echo "   ❓ Database migrations directory not found"
fi

# Check for seeders
if [ -d "database/seeders" ]; then
    SEEDER_COUNT=$(find database/seeders -name "*.php" | wc -l)
    if [ "$SEEDER_COUNT" -gt 0 ]; then
        echo "   💡 Found $SEEDER_COUNT seeder(s)"
        echo "   → Run: php artisan db:seed"
    fi
fi

# Check for model factories
if [ -d "database/factories" ]; then
    FACTORY_COUNT=$(find database/factories -name "*.php" | wc -l)
    if [ "$FACTORY_COUNT" -gt 0 ]; then
        echo "   🏭 Found $FACTORY_COUNT factorie(s)"
        echo "   → Use for testing: php artisan tinker"
        echo "   → Example: User::factory()->count(10)->create();"
    fi
fi

echo ""
echo "📚 Helpful commands:"
echo "   • Show migration status:     php artisan migrate:status"
echo "   • Run pending migrations:    php artisan migrate"
echo "   • Rollback last migration:   php artisan migrate:rollback"
echo "   • Fresh migrate (reset DB):  php artisan migrate:fresh --seed"
echo "   • Create new migration:     php artisan make:migration create_table_name"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit 0