# Vue.js Integration with Laravel

## Purpose

Guide for integrating Vue.js components with Laravel applications, particularly for use cases where Vue handles dynamic application features while Laravel Blade manages marketing and content pages.

## When to Use This Guide

Use when working on:
- Laravel applications with Vue.js frontends
- Hybrid Blade + Vue applications
- Laravel Inertia.js applications
- API-first Laravel with Vue SPAs

---

## Architecture Patterns

### Pattern 1: Blade + Vue Components (Marketing Pages)

```
Laravel Marketing Site
├── Blade Templates (static content)
│   ├── resources/views/marketing/landing.blade.php
│   ├── resources/views/marketing/about.blade.php
│   └── resources/views/layouts/marketing.blade.php
├── Vue Components (dynamic sections)
│   ├── resources/js/components/ContactForm.vue
│   ├── resources/js/components/TestimonialSlider.vue
│   └── resources/js/components/NewsletterSignup.vue
└── Vite Integration
    ├── resources/js/app.js
    └── vite.config.js
```

### Pattern 2: Laravel API + Vue SPA (Application)

```
Laravel Backend API
├── routes/api.php                    # API endpoints
├── app/Http/Controllers/API/         # API controllers
├── app/Models/                       # Eloquent models
└── app/Services/                     # Business logic

Vue.js Frontend SPA
├── resources/js/
│   ├── components/                   # Vue components
│   ├── views/                       # Vue router views
│   ├── stores/                      # Pinia stores
│   ├── services/                    # API service layer
│   └── app.js                       # Vue app entry
└── vite.config.js                   # Build config
```

---

## Blade + Vue Integration

### Loading Vue Components in Blade

```php
{{-- resources/views/layouts/app.blade.php --}}
<!DOCTYPE html>
<html>
<head>
    <title>{{ $title ?? config('app.name') }}</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body>
    <div id="app">
        {{-- Traditional Blade content --}}
        @include('partials.navigation')

        @yield('content')

        {{-- Vue mount points --}}
        <div id="vue-contact-form"></div>
        <div id="vue-testimonials"></div>

        @include('partials.footer')
    </div>
</body>
</html>
```

### Vue App Configuration

```javascript
// resources/js/app.js
import { createApp } from 'vue';
import ContactForm from './components/ContactForm.vue';
import TestimonialSlider from './components/TestimonialSlider.vue';

// Mount components on specific elements
const contactApp = createApp(ContactForm);
contactApp.mount('#vue-contact-form');

const testimonialApp = createApp(TestimonialSlider);
testimonialApp.mount('#vue-testimonials');

// Global Vue app for SPA sections
import App from './App.vue';
import router from './router';
import { createPinia } from 'pinia';

const spaApp = createApp(App);
spaApp.use(router);
spaApp.use(createPinia());
spaApp.mount('#vue-spa');
```

### Blade Component with Vue Integration

```blade
{{-- resources/views/components/contact-form.blade.php --}}
@props(['submitRoute' => route('contact.submit')])

<div class="contact-form-container">
    <h3>Contact Us</h3>
    <div id="vue-contact-form" data-route="{{ $submitRoute }}"></div>
</div>

@push('scripts')
<script>
    // Pass data to Vue component
    window.contactFormConfig = {
        submitRoute: '{{ $submitRoute }}',
        csrfToken: '{{ csrf_token() }}'
    };
</script>
@endpush
```

```vue
<!-- resources/js/components/ContactForm.vue -->
<template>
    <form @submit.prevent="submitForm" class="contact-form">
        <div class="form-group">
            <label for="name">Name</label>
            <input
                id="name"
                v-model="form.name"
                type="text"
                class="form-control"
                :class="{ 'is-invalid': errors.name }"
                required
            >
            <div v-if="errors.name" class="invalid-feedback">
                {{ errors.name }}
            </div>
        </div>

        <div class="form-group">
            <label for="email">Email</label>
            <input
                id="email"
                v-model="form.email"
                type="email"
                class="form-control"
                :class="{ 'is-invalid': errors.email }"
                required
            >
            <div v-if="errors.email" class="invalid-feedback">
                {{ errors.email }}
            </div>
        </div>

        <div class="form-group">
            <label for="message">Message</label>
            <textarea
                id="message"
                v-model="form.message"
                class="form-control"
                rows="4"
                :class="{ 'is-invalid': errors.message }"
                required
            ></textarea>
            <div v-if="errors.message" class="invalid-feedback">
                {{ errors.message }}
            </div>
        </div>

        <button type="submit" class="btn btn-primary" :disabled="loading">
            <span v-if="!loading">Send Message</span>
            <span v-else>
                <i class="fas fa-spinner fa-spin"></i> Sending...
            </span>
        </button>

        <div v-if="success" class="alert alert-success mt-3">
            Thank you for your message! We'll get back to you soon.
        </div>

        <div v-if="error" class="alert alert-danger mt-3">
            {{ error }}
        </div>
    </form>
</template>

<script>
import { ref, reactive } from 'vue';

export default {
    name: 'ContactForm',
    setup() {
        const loading = ref(false);
        const success = ref(false);
        const error = ref('');
        const errors = ref({});

        const form = reactive({
            name: '',
            email: '',
            message: ''
        });

        const submitRoute = window.contactFormConfig?.submitRoute || '/contact';

        const submitForm = async () => {
            loading.value = true;
            error.value = '';
            success.value = false;
            errors.value = {};

            try {
                const response = await fetch(submitRoute, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': window.contactFormConfig?.csrfToken
                    },
                    body: JSON.stringify(form)
                });

                const data = await response.json();

                if (response.ok) {
                    success.value = true;
                    // Reset form
                    Object.keys(form).forEach(key => {
                        form[key] = '';
                    });
                } else {
                    if (data.errors) {
                        errors.value = data.errors;
                    } else {
                        error.value = data.message || 'An error occurred. Please try again.';
                    }
                }
            } catch (err) {
                error.value = 'Network error. Please try again.';
            } finally {
                loading.value = false;
            }
        };

        return {
            form,
            loading,
            success,
            error,
            errors,
            submitForm
        };
    }
};
</script>

<style scoped>
.contact-form {
    max-width: 500px;
}
</style>
```

---

## Laravel API + Vue SPA

### Laravel API Setup

```php
// routes/api.php
use App\Http\Controllers\API\UserController;
use App\Http\Controllers\API\ProjectController;
use Illuminate\Support\Facades\Route;

Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('users', UserController::class);
    Route::apiResource('projects', ProjectController::class);
    Route::get('/profile', [UserController::class, 'profile']);
});
```

```php
// app/Http/Controllers/API/ProjectController.php
namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Project;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ProjectController extends Controller
{
    public function index(): JsonResponse
    {
        $projects = Project::with(['user', 'tasks'])
            ->where('user_id', auth()->id())
            ->latest()
            ->paginate(10);

        return response()->json($projects);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'status' => 'in:planning,in_progress,completed',
        ]);

        $project = auth()->user()->projects()->create($validated);

        return response()->json($project, 201);
    }
}
```

### Vue API Service Layer

```javascript
// resources/js/services/api.js
import axios from 'axios';

const api = axios.create({
    baseURL: '/api',
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    }
});

// Add CSRF token for Laravel
const token = document.querySelector('meta[name="csrf-token"]');
if (token) {
    api.defaults.headers.common['X-CSRF-TOKEN'] = token.getAttribute('content');
}

// Add auth token if available
const authToken = localStorage.getItem('authToken');
if (authToken) {
    api.defaults.headers.common['Authorization'] = `Bearer ${authToken}`;
}

// Response interceptor for error handling
api.interceptors.response.use(
    response => response,
    error => {
        if (error.response?.status === 401) {
            // Handle unauthorized
            localStorage.removeItem('authToken');
            window.location.href = '/login';
        }
        return Promise.reject(error);
    }
);

export default api;

// Specific API services
export const projectApi = {
    getAll: (params = {}) => api.get('/projects', { params }),
    get: (id) => api.get(`/projects/${id}`),
    create: (data) => api.post('/projects', data),
    update: (id, data) => api.put(`/projects/${id}`, data),
    delete: (id) => api.delete(`/projects/${id}`),
};

export const userApi = {
    profile: () => api.get('/profile'),
    update: (data) => api.put('/profile', data),
};
```

### Vue with Pinia Store

```javascript
// resources/js/stores/projects.js
import { defineStore } from 'pinia';
import { projectApi } from '@/services/api';

export const useProjectStore = defineStore('projects', {
    state: () => ({
        projects: [],
        currentProject: null,
        loading: false,
        error: null,
    }),

    getters: {
        completedProjects: (state) => {
            return state.projects.filter(p => p.status === 'completed');
        },

        activeProjects: (state) => {
            return state.projects.filter(p => p.status === 'in_progress');
        }
    },

    actions: {
        async fetchProjects() {
            this.loading = true;
            this.error = null;

            try {
                const response = await projectApi.getAll();
                this.projects = response.data.data;
            } catch (error) {
                this.error = error.response?.data?.message || 'Failed to fetch projects';
            } finally {
                this.loading = false;
            }
        },

        async createProject(projectData) {
            try {
                const response = await projectApi.create(projectData);
                this.projects.unshift(response.data);
                return response.data;
            } catch (error) {
                throw new Error(error.response?.data?.message || 'Failed to create project');
            }
        }
    }
});
```

---

## Vite Configuration for Laravel

### Vite Config

```javascript
// vite.config.js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
        }),
    ],
    resolve: {
        alias: {
            '@': '/resources/js',
        },
    },
    build: {
        outDir: 'public/build',
        manifest: true,
        rollupOptions: {
            output: {
                manualChunks: {
                    vendor: ['vue', 'axios'],
                },
            },
        },
    },
});
```

### Laravel Vite Plugin

```bash
# Install Laravel Vite plugin
npm install laravel-vite-plugin --save-dev
```

---

## Component Organization

### Vue Component Structure

```
resources/js/
├── components/
│   ├── common/              # Reusable components
│   │   ├── BaseButton.vue
│   │   ├── BaseModal.vue
│   │   └── LoadingSpinner.vue
│   ├── forms/               # Form components
│   │   ├── ContactForm.vue
│   │   ├── ProjectForm.vue
│   │   └── SearchForm.vue
│   └── features/            # Feature-specific components
│       ├── ProjectCard.vue
│       ├── TaskList.vue
│       └── UserProfile.vue
├── composables/             # Vue composables
│   ├── useApi.js
│   ├── useAuth.js
│   └── useNotifications.js
├── stores/                  # Pinia stores
│   ├── auth.js
│   ├── projects.js
│   └── ui.js
├── services/                # API services
│   ├── api.js
│   ├── auth.js
│   └── projects.js
├── router/                  # Vue Router
│   └── index.js
├── views/                   # Page components
│   ├── Dashboard.vue
│   ├── Projects.vue
│   └── Profile.vue
├── App.vue                  # Root component
└── app.js                   # Entry point
```

---

## Best Practices

### 1. Communication Between Blade and Vue

```php
{{-- Pass data from Laravel to Vue --}}
<div id="vue-component" :data-user='@json($user)'></div>

<script>
// Access in Vue
const userData = JSON.parse(document.getElementById('vue-component').dataset.user);
</script>
```

### 2. SEO Considerations

- Use Blade for SEO-critical content (headings, meta tags)
- Vue for interactive components (forms, modals, dynamic lists)
- Implement proper meta tags for SPA routes if needed

### 3. Performance Optimization

- Lazy load Vue components
- Use Vite's code splitting
- Implement proper caching strategies
- Minimize bundle size with tree shaking

### 4. Error Handling

- Global Vue error handler
- Axios interceptors for API errors
- Laravel validation error handling
- User-friendly error messages

---

## Testing Vue Components with Laravel

### Component Testing Setup

```javascript
// tests/Component/ContactForm.test.js
import { mount } from '@vue/test-utils';
import ContactForm from '@/components/ContactForm.vue';

describe('ContactForm', () => {
    it('submits form correctly', async () => {
        const wrapper = mount(ContactForm);

        await wrapper.find('#name').setValue('John Doe');
        await wrapper.find('#email').setValue('john@example.com');
        await wrapper.find('#message').setValue('Test message');

        await wrapper.find('form').trigger('submit.prevent');

        expect(wrapper.emitted('submit')).toBeTruthy();
    });
});
```

---

## Migration Strategy

### Step 1: Identify Components
- Static content → Keep in Blade
- Interactive elements → Convert to Vue
- Forms → Vue with Laravel API validation

### Step 2: Incremental Migration
1. Start with isolated components (contact forms, search)
2. Gradually replace complex sections
3. Maintain backward compatibility
4. Test thoroughly at each step

### Step 3: Full SPA Transition (Optional)
- Migrate all Blade pages to Vue Router
- Implement proper authentication
- Handle SEO considerations
- Set up proper error boundaries