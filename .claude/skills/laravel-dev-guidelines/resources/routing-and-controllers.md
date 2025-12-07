# Laravel Routes and Controllers

## Route Organization

### Route Files

```
routes/
├── api.php              # API routes (stateless)
├── web.php              # Web routes (session-based)
├── console.php          # Artisan commands
└── channels.php         # Broadcasting channels
```

### API Routes (RESTful)

```php
// routes/api.php
Route::prefix('v1')->group(function () {
    Route::apiResource('users', UserController::class);

    Route::prefix('auth')->group(function () {
        Route::post('login', [AuthController::class, 'login']);
        Route::post('logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
        Route::post('refresh', [AuthController::class, 'refresh']);
    });

    Route::middleware(['auth:sanctum', 'throttle:60,1'])->group(function () {
        Route::apiResource('posts', PostController::class);
        Route::apiResource('comments', CommentController::class);
    });
});
```

### Web Routes (Traditional)

```php
// routes/web.php
Route::get('/', [HomeController::class, 'index'])->name('home');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    Route::resource('profile', ProfileController::class)->only(['edit', 'update']);
});

Route::prefix('admin')->middleware(['auth', 'admin'])->group(function () {
    Route::resource('users', Admin\UserController::class);
});
```

---

## Controller Patterns

### BaseController Structure

```php
// app/Http/Controllers/BaseController.php
namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

abstract class BaseController extends Controller
{
    /**
     * Success response
     */
    protected function successResponse(
        mixed $data = null,
        string $message = 'Success',
        int $status = 200
    ): JsonResponse {
        $response = [
            'success' => true,
            'message' => $message,
        ];

        if ($data !== null) {
            if ($data instanceof JsonResource) {
                $response['data'] = $data->response()->getData(true);
            } elseif ($data instanceof LengthAwarePaginator) {
                $response['data'] = $data->items();
                $response['meta'] = [
                    'current_page' => $data->currentPage(),
                    'per_page' => $data->perPage(),
                    'total' => $data->total(),
                    'last_page' => $data->lastPage(),
                ];
            } elseif ($data instanceof Collection) {
                $response['data'] = $data->toArray();
            } else {
                $response['data'] = $data;
            }
        }

        return response()->json($response, $status);
    }

    /**
     * Error response
     */
    protected function errorResponse(
        string $message = 'Error',
        mixed $errors = null,
        int $status = 400
    ): JsonResponse {
        $response = [
            'success' => false,
            'message' => $message,
        ];

        if ($errors !== null) {
            $response['errors'] = $errors;
        }

        return response()->json($response, $status);
    }

    /**
     * Validation error response
     */
    protected function validationErrorResponse(
        array $errors,
        string $message = 'Validation failed'
    ): JsonResponse {
        return $this->errorResponse($message, $errors, 422);
    }
}
```

### API Controller Example

```php
// app/Http/Controllers/Api/v1/UserController.php
namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\BaseController;
use App\Http\Requests\StoreUserRequest;
use App\Http\Requests\UpdateUserRequest;
use App\Services\UserServiceInterface;
use App\Http\Resources\UserResource;
use Illuminate\Http\JsonResponse;

class UserController extends BaseController
{
    public function __construct(
        private UserServiceInterface $userService
    ) {}

    /**
     * Display a paginated listing of users
     */
    public function index(IndexUserRequest $request): JsonResponse
    {
        $users = $this->userService->getPaginatedUsers(
            filters: $request->validated(),
            perPage: $request->per_page ?? 15
        );

        return $this->successResponse($users);
    }

    /**
     * Store a newly created user
     */
    public function store(StoreUserRequest $request): JsonResponse
    {
        try {
            $user = $this->userService->create($request->validated());

            return $this->successResponse(
                new UserResource($user),
                'User created successfully',
                201
            );
        } catch (Exception $e) {
            Sentry::captureException($e);
            return $this->errorResponse(
                'Failed to create user',
                null,
                500
            );
        }
    }

    /**
     * Display the specified user
     */
    public function show(ShowUserRequest $request): JsonResponse
    {
        $user = $this->userService->findById($request->route('id'));

        return $this->successResponse(new UserResource($user));
    }

    /**
     * Update the specified user
     */
    public function update(UpdateUserRequest $request): JsonResponse
    {
        try {
            $user = $this->userService->update(
                id: $request->route('id'),
                data: $request->validated()
            );

            return $this->successResponse(
                new UserResource($user),
                'User updated successfully'
            );
        } catch (Exception $e) {
            Sentry::captureException($e);
            return $this->errorResponse(
                'Failed to update user',
                null,
                500
            );
        }
    }

    /**
     * Remove the specified user
     */
    public function destroy(DestroyUserRequest $request): JsonResponse
    {
        try {
            $this->userService->delete($request->route('id'));

            return $this->successResponse(
                null,
                'User deleted successfully',
                204
            );
        } catch (Exception $e) {
            Sentry::captureException($e);
            return $this->errorResponse(
                'Failed to delete user',
                null,
                500
            );
        }
    }
}
```

### Web Controller Example

```php
// app/Http/Controllers/DashboardController.php
namespace App\Http\Controllers;

use App\Services\DashboardServiceInterface;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function __construct(
        private DashboardServiceInterface $dashboardService
    ) {}

    /**
     * Display the user dashboard
     */
    public function index(): View
    {
        $data = $this->dashboardService->getUserDashboardData(
            userId: auth()->id()
        );

        return view('dashboard.index', $data);
    }
}
```

---

## Route Model Binding

### Implicit Binding

```php
// routes/web.php or api.php
Route::get('users/{user}', [UserController::class, 'show']);

// Controller
public function show(User $user): JsonResponse
{
    // Laravel automatically resolves User by ID
    return $this->successResponse($user);
}
```

### Custom Key Binding

```php
// Route model binding in RouteServiceProvider
Route::model('user', User::class);
Route::bind('user:slug', function ($value) {
    return User::where('slug', $value)->firstOrFail();
});
```

### Explicit Binding

```php
// app/Providers/RouteServiceProvider.php
public function boot(): void
{
    Route::bind('post', function ($value) {
        return Post::with(['user', 'comments'])
            ->where('uuid', $value)
            ->firstOrFail();
    });
}
```

---

## Route Groups and Middleware

### API Versioning

```php
Route::prefix('api/v1')->as('api.v1.')->group(function () {
    Route::apiResource('users', UserController::class);
});

Route::prefix('api/v2')->as('api.v2.')->group(function () {
    // Version 2 routes
});
```

### Middleware Groups

```php
Route::middleware(['auth:sanctum', 'verified'])->group(function () {
    Route::apiResource('posts', PostController::class);
    Route::apiResource('comments', CommentController::class);
});

Route::middleware(['throttle:api'])->prefix('api')->group(function () {
    // Rate limited API routes
});
```

### Subdomain Routing

```php
Route::domain('api.' . config('app.url'))->group(function () {
    Route::get('users', [UserController::class, 'index']);
});

Route::domain('{account}.example.com')->group(function () {
    Route::get('dashboard', [TenantController::class, 'dashboard']);
});
```

---

## API Resources

### Resource Collection

```php
// app/Http/Resources/UserCollection.php
namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\ResourceCollection;

class UserCollection extends ResourceCollection
{
    public function toArray($request): array
    {
        return [
            'data' => UserResource::collection($this->collection),
            'meta' => [
                'total' => $this->collection->count(),
                'links' => [
                    'self' => url('/users'),
                ],
            ],
        ];
    }
}
```

### Single Resource

```php
// app/Http/Resources/UserResource.php
namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->uuid,
            'name' => $this->name,
            'email' => $this->email,
            'avatar' => $this->avatar_url,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'relationships' => [
                'posts' => PostResource::collection($this->whenLoaded('posts')),
                'comments' => CommentResource::collection($this->whenLoaded('comments')),
            ],
        ];
    }
}
```

### Conditional Data

```php
public function toArray(Request $request): array
{
    return [
        'id' => $this->id,
        'name' => $this->name,
        'email' => $this->when($request->user()?->isAdmin(), $this->email),
        'secret_field' => $this->whenLoaded('secretRelation'),
        'profile_complete' => $this->whenNotNull($this->profile_completed_at),
    ];
}
```

---

## Route Caching

### Cache Routes (Production)

```bash
php artisan route:cache
php artisan route:clear
```

### Route Registration Order

```php
// Register specific routes before generic ones
Route::get('users/search', [UserController::class, 'search']);
Route::get('users/{user}', [UserController::class, 'show']);
```

---

## Best Practices

### Controller Guidelines

1. **Single Responsibility**: Controllers handle HTTP only
2. **Dependency Injection**: Inject services via constructor
3. **Thin Controllers**: Keep logic minimal, delegate to services
4. **Consistent Responses**: Use BaseController methods
5. **Error Handling**: Wrap service calls in try-catch

### Route Organization

1. **Version APIs**: Use version prefixes for APIs
2. **Logical Grouping**: Group related routes
3. **Middleware Usage**: Apply appropriate middleware
4. **Resource Routes**: Use Route::apiResource for CRUD
5. **Route Naming**: Use descriptive names for routes

### Response Patterns

1. **Standardized Format**: Consistent success/error response format
2. **HTTP Status Codes**: Use appropriate status codes
3. **Data Transformation**: Use API Resources
4. **Pagination**: Include meta information for paginated data
5. **Error Details**: Provide helpful error messages