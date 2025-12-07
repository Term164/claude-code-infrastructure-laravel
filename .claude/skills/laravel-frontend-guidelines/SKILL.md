---
name: laravel-frontend-guidelines
description: Comprehensive Laravel frontend development guide for Blade templates and Vite integration. Use when creating Blade views, components, layouts, or working with Laravel's frontend stack including Blade, Livewire, Alpine.js, and Vite. Covers Blade patterns, component organization, asset management, responsive design, and integration with modern JavaScript frameworks.
---

# Laravel Frontend Development Guidelines

## Purpose

Establish consistency and best practices for Laravel frontend development using Blade templates, Blade Components, Livewire, and Vite for asset compilation.

## When to Use This Skill

Automatically activates when working on:
- Creating or modifying Blade templates or views
- Building Blade components
- Integrating with Livewire components
- Managing frontend assets with Vite
- Implementing responsive design patterns
- Working with Alpine.js interactions
- Optimizing frontend performance

---

## Quick Start

### New Frontend Feature Checklist

- [ ] **Layout**: Use existing layout or create new layout
- [ ] **Blade Component**: Create reusable Blade components
- [ ] **Asset Management**: Organize CSS/JS with Vite
- [ ] **Responsive Design**: Mobile-first approach
- [ ] **Accessibility**: ARIA labels and semantic HTML
- [ ] **Performance**: Optimized asset loading
- [ ] **SEO**: Meta tags and structured data

### New Laravel Application Frontend Checklist

- [ ] Directory structure (see [architecture-overview.md](architecture-overview.md))
- [ ] Vite configuration
- [ ] Blade component library setup
- [ ] CSS framework integration (Bootstrap/Tailwind)
- [ ] JavaScript framework setup (Alpine.js/Livewire)
- [ ] Asset optimization strategy

---

## Architecture Overview

### Frontend Stack Integration

```
Laravel Backend
    ↓
Blade Templates (Views)
    ↓
Blade Components (Reusable UI)
    ↓
Vite (Asset Compilation)
    ↓
CSS/JavaScript (Frontend Assets)
    ↓
Browser
```

### Technology Stack

- **Blade**: Laravel's templating engine
- **Blade Components**: Reusable UI components
- **Livewire**: Dynamic components without full page reloads
- **Alpine.js**: Lightweight JavaScript for interactions
- **Vite**: Fast asset bundler and development server
- **CSS Framework**: Bootstrap 5 or Tailwind CSS

---

## Directory Structure

```
resources/
├── views/
│   ├── layouts/              # Master layouts
│   │   ├── app.blade.php     # Main layout
│   │   ├── auth.blade.php    # Auth pages layout
│   │   └── admin.blade.php   # Admin layout
│   ├── components/           # Blade components
│   │   ├── forms/            # Form components
│   │   ├── ui/               # UI components
│   │   └── admin/            # Admin components
│   ├── pages/                # Page views
│   │   ├── auth/             # Auth pages
│   │   ├── dashboard/        # Dashboard pages
│   │   └── profile/          # Profile pages
│   ├── partials/             # Reusable partials
│   │   ├── navigation.blade.php
│   │   ├── sidebar.blade.php
│   │   └── footer.blade.php
│   └── emails/               # Email templates
├── css/
│   ├── app.css               # Main stylesheet
│   └── components/           # Component-specific CSS
├── js/
│   ├── app.js                # Main JavaScript file
│   ├── bootstrap.js          # Laravel bootstrap
│   └── components/           # Component-specific JS
└── img/                      # Static images
```

**Naming Conventions:**
- Views: `kebab-case` - `user-profile.blade.php`
- Components: `PascalCase` - `UserProfile.blade.php`
- CSS: `kebab-case` - `user-profile.css`
- JS: `PascalCase` - `UserProfile.js`

---

## Core Principles (7 Key Rules)

### 1. Use Blade Components for Reusability

```blade
<!-- ❌ NEVER: Duplicate HTML -->
<div class="card">
    <h3>Title 1</h3>
    <p>Content 1</p>
</div>

<div class="card">
    <h3>Title 2</h3>
    <p>Content 2</p>
</div>

<!-- ✅ ALWAYS: Create components -->
<x-card title="Title 1">
    <p>Content 1</p>
</x-card>

<x-card title="Title 2">
    <p>Content 2</p>
</x-card>
```

### 2. Mobile-First Responsive Design

```css
/* Base styles for mobile */
.container {
    padding: 1rem;
}

/* Responsive breakpoints */
@media (min-width: 768px) {
    .container {
        padding: 2rem;
    }
}
```

### 3. Semantic HTML and Accessibility

```blade
<!-- ✅ ALWAYS: Use semantic HTML -->
<main role="main" aria-label="Main content">
    <section aria-labelledby="users-heading">
        <h2 id="users-heading">Users</h2>
        <!-- Content -->
    </section>
</main>

<!-- ✅ ALWAYS: Include accessibility attributes -->
<button
    type="button"
    aria-label="Close dialog"
    aria-expanded="false"
    aria-controls="user-modal"
>
    Close
</button>
```

### 4. Organize Assets with Vite

```javascript
// resources/js/app.js
import './bootstrap';
import './components';

// Import CSS
import '../css/app.css';

// Import Alpine.js
import Alpine from 'alpinejs';
window.Alpine = Alpine;
Alpine.start();
```

### 5. Use Livewire for Dynamic Interactions

```php
// app/Livewire/UserSearch.php
class UserSearch extends Component
{
    public $search = '';
    public $users = [];

    public function updatedSearch()
    {
        $this->users = User::where('name', 'like', '%'.$this->search.'%')
                           ->limit(10)
                           ->get();
    }

    public function render()
    {
        return view('livewire.user-search');
    }
}
```

### 6. Optimize Asset Loading

```blade
{{-- Load CSS asynchronously --}}
<link
    rel="preload"
    href="{{ asset('css/app.css') }}"
    as="style"
    onload="this.onload=null;this.rel='stylesheet'"
>

{{-- Defer non-critical JavaScript --}}
<script src="{{ asset('js/app.js') }}" defer></script>
```

### 7. Progressive Enhancement

```blade
{{-- Basic HTML that works without JavaScript --}}
<form action="{{ route('users.store') }}" method="POST">
    @csrf
    <input type="text" name="name" required>
    <button type="submit">Save</button>
</form>

{{-- Enhanced with JavaScript (Alpine.js) --}}
<div x-data="{ name: '' }">
    <input
        type="text"
        x-model="name"
        :required="!name"
        @keyup.enter="$root.submit()"
    >
    <button
        type="button"
        @click="$root.submit()"
        :disabled="!name"
    >
        Save
    </button>
</div>
```

---

## Common Patterns

### Blade Component Structure

```php
// app/View/Components/Card.php
namespace App\View\Components;

use Illuminate\View\Component;
use Illuminate\View\View;

class Card extends Component
{
    public function __construct(
        public string $title = '',
        public string $variant = 'default',
        public bool $collapsible = false
    ) {}

    public function render(): View
    {
        return view('components.card');
    }
}
```

```blade
{{-- resources/views/components/card.blade.php --}}
@props(['title', 'variant' => 'default', 'collapsible' => false])

<div {{ $attributes->merge(['class' => "card card-{$variant}"]) }}>
    @if($title)
        <div class="card-header d-flex justify-content-between align-items-center">
            <h3 class="card-title">{{ $title }}</h3>
            @if($collapsible)
                <button
                    type="button"
                    class="btn btn-sm"
                    data-bs-toggle="collapse"
                    data-bs-target="#{{ $attributes->get('id') }}-body"
                >
                    <i class="fas fa-chevron-down"></i>
                </button>
            @endif
        </div>
    @endif

    <div class="card-body @if($collapsible) collapse @endif" id="{{ $attributes->get('id') }}-body">
        {{ $slot }}
    </div>
</div>
```

### Layout Patterns

```blade
{{-- resources/views/layouts/app.blade.php --}}
<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ $pageTitle ?? config('app.name') }}</title>

    {{-- SEO Meta --}}
    @if($description ?? null)
        <meta name="description" content="{{ $description }}">
    @endif

    {{-- CSRF Token --}}
    <meta name="csrf-token" content="{{ csrf_token() }}">

    {{-- Assets --}}
    @vite(['resources/css/app.css', 'resources/js/app.js'])

    {{-- Additional head content --}}
    @stack('head')
</head>
<body class="{{ $bodyClass ?? '' }}">
    <div id="app">
        {{-- Navigation --}}
        @include('partials.navigation')

        {{-- Main Content --}}
        <main class="main-content">
            @yield('content')
        </main>

        {{-- Footer --}}
        @include('partials.footer')
    </div>

    {{-- Modal Container --}}
    <div id="modal-container"></div>

    {{-- Flash Messages --}}
    @include('partials.flash-messages')

    {{-- Additional scripts --}}
    @stack('scripts')
</body>
</html>
```

### Form Components

```blade
{{-- resources/views/components/forms/input.blade.php --}}
@props([
    'name',
    'label',
    'type' => 'text',
    'value' => null,
    'required' => false,
    'error' => null,
    'placeholder' => '',
    'help' => null
])

<div class="form-group mb-3">
    @if($label)
        <label for="{{ $name }}" class="form-label">
            {{ $label }}
            @if($required)
                <span class="text-danger">*</span>
            @endif
        </label>
    @endif

    <input
        type="{{ $type }}"
        id="{{ $name }}"
        name="{{ $name }}"
        value="{{ old($name, $value) }}"
        placeholder="{{ $placeholder }}"
        class="form-control @error($name) is-invalid @enderror"
        @if($required) required @endif
        {{ $attributes }}
    >

    @if($error)
        <div class="invalid-feedback d-block">
            {{ $error }}
        </div>
    @elseif($help)
        <small class="form-text text-muted">{{ $help }}</small>
    @endif
</div>
```

---

## Integration with Modern Frontend

### Alpine.js Patterns

```blade
<div x-data="{
    open: false,
    user: @json($user ?? null),
    loading: false
}">
    {{-- Toggle visibility --}}
    <button @click="open = !open" x-text="open ? 'Close' : 'Open'"></button>

    <div x-show="open" x-transition>
        <!-- Content -->
    </div>

    {{-- API call --}}
    <button
        @click="loading = true;
               $fetch('/api/users/' + user.id, { method: 'PATCH' })
                   .then(response => user = response.data)
                   .finally(() => loading = false)"
        :disabled="loading"
    >
        <span x-show="!loading">Update User</span>
        <span x-show="loading">Updating...</span>
    </button>
</div>
```

### Livewire Integration

```blade
{{-- resources/views/livewire/user-search.blade.php --}}
<div>
    {{-- Search Input --}}
    <input
        type="text"
        wire:model.live="search"
        placeholder="Search users..."
        class="form-control"
    >

    {{-- Loading State --}}
    @if($this->updatingProperty('search'))
        <div class="spinner-border spinner-border-sm" role="status">
            <span class="visually-hidden">Loading...</span>
        </div>
    @endif

    {{-- Results --}}
    @if($search && $users->count() > 0)
        <div class="list-group mt-3">
            @foreach($users as $user)
                <div class="list-group-item">
                    <h6>{{ $user->name }}</h6>
                    <small class="text-muted">{{ $user->email }}</small>
                </div>
            @endforeach
        </div>
    @elseif($search)
        <div class="alert alert-info mt-3">
            No users found for "{{ $search }}"
        </div>
    @endif
</div>
```

---

## Navigation Guide

| Need to... | Read this |
|------------|-----------|
| Understand frontend architecture | [architecture-overview.md](architecture-overview.md) |
| Create Blade components | [blade-components.md](blade-components.md) |
| Build responsive layouts | [responsive-design.md](responsive-design.md) |
| Work with forms | [form-patterns.md](form-patterns.md) |
| Add interactivity | [javascript-integration.md](javascript-integration.md) |
| Optimize performance | [performance-optimization.md](performance-optimization.md) |
| Accessibility guidelines | [accessibility-guide.md](accessibility-guide.md) |
| See examples | [complete-examples.md](complete-examples.md) |

---

## Related Skills

- **laravel-dev-guidelines** - Laravel backend development patterns
- **skill-developer** - Meta-skill for creating and managing skills

---

**Skill Status**: COMPLETE ✅
**Line Count**: < 500 ✅
**Progressive Disclosure**: 8 resource files ✅