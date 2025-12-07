#!/bin/bash

# Vue Build Check Hook for Laravel + Vue projects
# Runs on stop to check if Vue assets need building

# Check if this is a Vue project
if [ ! -f "vite.config.js" ] && [ ! -f "vite.config.ts" ]; then
    exit 0
fi

# Check if we're in a Laravel project
if [ ! -f "artisan" ]; then
    exit 0
fi

echo ""
echo "🔍 Vue Build Status Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check npm dependencies
if [ ! -d "node_modules" ]; then
    echo "❓ Node modules missing"
    echo "   → Run: npm install"
    echo ""
    exit 0
fi

# Check if build directory exists
if [ ! -d "public/build" ]; then
    echo "❓ Frontend build directory missing"
    echo "   → Run: npm run build"
    echo ""
    exit 0
fi

# Check if manifest.json exists (Vite manifest)
if [ ! -f "public/build/manifest.json" ]; then
    echo "❓ Vite manifest missing"
    echo "   → Run: npm run build"
    echo ""
    exit 0
fi

# Check if frontend sources are newer than build
NEEDS_BUILD=false

# Check main app file
if [ -f "resources/js/app.js" ] && [ "resources/js/app.js" -nt "public/build" ]; then
    NEEDS_BUILD=true
fi

# Check for Vue components
if [ -d "resources/js/components" ]; then
    if find resources/js/components -name "*.vue" -newer public/build 2>/dev/null | grep -q .; then
        NEEDS_BUILD=true
    fi
fi

# Check package.json changes
if [ -f "package.json" ] && [ "package.json" -nt "public/build" ]; then
    NEEDS_BUILD=true
fi

# Check Vite config changes
if [ -f "vite.config.js" ] && [ "vite.config.js" -nt "public/build" ]; then
    NEEDS_BUILD=true
fi

if [ -f "vite.config.ts" ] && [ "vite.config.ts" -nt "public/build" ]; then
    NEEDS_BUILD=true
fi

if [ "$NEEDS_BUILD" = true ]; then
    echo "🔄 Frontend assets need rebuilding"
    echo "   → Run: npm run dev    (for development)"
    echo "   → Run: npm run build  (for production)"
    echo ""
    echo "💡 Tip: Use 'npm run dev' during development for hot reload"
else
    echo "✅ Frontend build is up to date"
fi

# Check for common Vue issues
echo ""
echo "🔧 Development Environment Check:"

# Check if @vite/plugin/laravel is installed
if [ -f "package.json" ]; then
    if grep -q "@vite/plugin/laravel" package.json; then
        echo "   ✅ Laravel Vite plugin detected"
    else
        echo "   ❓ Consider installing Laravel Vite plugin:"
        echo "      npm install @vite/plugin/laravel --save-dev"
    fi
fi

# Check for Vue dependencies
if [ -f "package.json" ]; then
    if grep -q '"vue"' package.json; then
        echo "   ✅ Vue.js detected"
    else
        echo "   ❓ Vue.js not found in dependencies"
    fi

    if grep -q "pinia" package.json; then
        echo "   ✅ Pinia state management detected"
    fi

    if grep -q "vue-router" package.json; then
        echo "   ✅ Vue Router detected"
    fi
fi

# Check Laravel + Vue integration
if [ -f "resources/js/bootstrap.js" ]; then
    echo "   ✅ Laravel bootstrap file found"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit 0