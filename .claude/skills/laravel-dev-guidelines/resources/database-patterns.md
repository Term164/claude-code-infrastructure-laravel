# Laravel Database Patterns

## Eloquent Models

### Base Model Structure

```php
// app/Models/User.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    /**
     * The attributes that are mass assignable
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'phone',
        'avatar',
        'settings',
    ];

    /**
     * The attributes that should be hidden for serialization
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'settings' => 'array',
        'created_at' => 'datetime:Y-m-d H:i:s',
        'updated_at' => 'datetime:Y-m-d H:i:s',
    ];

    /**
     * The accessors to append to the model's array form
     */
    protected $appends = [
        'avatar_url',
    ];

    /**
     * Get the user's avatar URL
     */
    public function getAvatarUrlAttribute(): string
    {
        return $this->avatar
            ? Storage::url($this->avatar)
            : 'https://ui-avatars.com/api/?name=' . urlencode($this->name);
    }
}
```

### Relationships

```php
// app/Models/Post.php
class Post extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'title',
        'content',
        'status',
        'published_at',
    ];

    protected $casts = [
        'published_at' => 'datetime',
        'meta' => 'json',
    ];

    /**
     * Get the author of the post
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the comments for the post
     */
    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class);
    }

    /**
     * Get the published comments
     */
    public function publishedComments(): HasMany
    {
        return $this->comments()->where('status', 'published');
    }

    /**
     * Get the tags for the post
     */
    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(Tag::class)
            ->withTimestamps()
            ->withPivot('sort_order');
    }

    /**
     * Get the featured image
     */
    public function featuredImage(): HasOne
    {
        return $this->hasOne(Media::class)
            ->where('type', 'featured_image');
    }

    /**
     * Get all media for the post
     */
    public function media(): MorphMany
    {
        return $this->morphMany(Media::class, 'mediable');
    }

    /**
     * Get all views for the post
     */
    public function views(): MorphMany
    {
        return $this->morphMany(View::class, 'viewable');
    }
}
```

### Scopes

```php
// app/Models/Post.php (continued)

/**
 * Scope a query to only include published posts
 */
public function scopePublished(Builder $query): Builder
{
    return $query->where('status', 'published')
                ->whereNotNull('published_at')
                ->where('published_at', '<=', now());
}

/**
 * Scope a query to only include posts by a specific user
 */
public function scopeByUser(Builder $query, User|int $user): Builder
{
    $userId = $user instanceof User ? $user->id : $user;
    return $query->where('user_id', $userId);
}

/**
 * Scope a query to include popular posts (most views in last 30 days)
 */
public function scopePopular(Builder $query, int $days = 30): Builder
{
    return $query->withCount(['views' => function ($query) use ($days) {
        $query->where('created_at', '>=', now()->subDays($days));
    }])->orderByDesc('views_count');
}

/**
 * Scope a query to search posts
 */
public function scopeSearch(Builder $query, string $term): Builder
{
    return $query->where(function ($query) use ($term) {
        $query->where('title', 'like', "%{$term}%")
              ->orWhere('content', 'like', "%{$term}%");
    });
}
```

### Accessors and Mutators

```php
// app/Models/User.php (continued)

/**
 * Set the user's password attribute
 */
public function setPasswordAttribute(string $password): void
{
    $this->attributes['password'] = bcrypt($password);
}

/**
 * Get the user's full name
 */
public function getFullNameAttribute(): string
    {
    return "{$this->first_name} {$this->last_name}";
    }

/**
 * Get the user's formatted join date
 */
public function getJoinedAtAttribute(): string
{
    return $this->created_at->format('F j, Y');
}

/**
 * Check if user is admin
 */
public function getIsAdminAttribute(): bool
{
    return $this->role === 'admin';
}
```

---

## Repository Pattern

### Repository Interface

```php
// app/Repositories/Contracts/UserRepositoryInterface.php
namespace App\Repositories\Contracts;

use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

interface UserRepositoryInterface
{
    public function findById(int $id): ?User;
    public function findByEmail(string $email): ?User;
    public function create(array $data): User;
    public function update(int $id, array $data): User;
    public function delete(int $id): bool;
    public function paginateWithFilters(array $filters, int $perPage = 15): LengthAwarePaginator;
    public function all(): Collection;
    public function search(string $term): Collection;
    public function count(): int;
}
```

### Repository Implementation

```php
// app/Repositories/UserRepository.php
namespace App\Repositories;

use App\Models\User;
use App\Repositories\Contracts\UserRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

class UserRepository implements UserRepositoryInterface
{
    protected User $model;

    public function __construct(User $model)
    {
        $this->model = $model;
    }

    public function findById(int $id): ?User
    {
        return $this->model->find($id);
    }

    public function findByEmail(string $email): ?User
    {
        return $this->model->where('email', $email)->first();
    }

    public function create(array $data): User
    {
        return $this->model->create($data);
    }

    public function update(int $id, array $data): User
    {
        $user = $this->findById($id);
        $user->update($data);
        return $user->fresh();
    }

    public function delete(int $id): bool
    {
        return $this->model->destroy($id) > 0;
    }

    public function paginateWithFilters(array $filters, int $perPage = 15): LengthAwarePaginator
    {
        $query = $this->model->newQuery();

        return $query
            ->when(isset($filters['search']), function ($query) use ($filters) {
                $query->where(function ($query) use ($filters) {
                    $query->where('name', 'like', "%{$filters['search']}%")
                          ->orWhere('email', 'like', "%{$filters['search']}%");
                });
            })
            ->when(isset($filters['status']), function ($query) use ($filters) {
                $query->where('status', $filters['status']);
            })
            ->when(isset($filters['role']), function ($query) use ($filters) {
                $query->where('role', $filters['role']);
            })
            ->when(isset($filters['created_from']), function ($query) use ($filters) {
                $query->whereDate('created_at', '>=', $filters['created_from']);
            })
            ->when(isset($filters['created_to']), function ($query) use ($filters) {
                $query->whereDate('created_at', '<=', $filters['created_to']);
            })
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);
    }

    public function all(): Collection
    {
        return $this->model->all();
    }

    public function search(string $term): Collection
    {
        return $this->model
            ->where('name', 'like', "%{$term}%")
            ->orWhere('email', 'like', "%{$term}%")
            ->get();
    }

    public function count(): int
    {
        return $this->model->count();
    }
}
```

---

## Database Migrations

### Migration Examples

```php
// database/migrations/2024_01_01_000001_create_users_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->string('first_name');
            $table->string('last_name');
            $table->string('name')->virtualAs("CONCAT(first_name, ' ', last_name)");
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->string('phone')->nullable();
            $table->string('avatar')->nullable();
            $table->enum('role', ['user', 'admin', 'moderator'])->default('user');
            $table->enum('status', ['active', 'inactive', 'suspended'])->default('active');
            $table->json('settings')->nullable();
            $table->timestamp('last_login_at')->nullable();
            $table->string('last_login_ip')->nullable();
            $table->rememberToken();
            $table->timestamps();
            $table->softDeletes();

            // Indexes
            $table->index(['role', 'status']);
            $table->index('last_login_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
```

### Pivot Table Migration

```php
// database/migrations/2024_01_01_000003_create_post_tag_table.php
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('post_tag', function (Blueprint $table) {
            $table->id();
            $table->foreignId('post_id')->constrained()->onDelete('cascade');
            $table->foreignId('tag_id')->constrained()->onDelete('cascade');
            $table->integer('sort_order')->default(0);
            $table->timestamps();

            // Composite unique index
            $table->unique(['post_id', 'tag_id']);
            $table->index('sort_order');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('post_tag');
    }
};
```

---

## Query Optimization

### Eager Loading

```php
// Bad: N+1 Query Problem
$posts = Post::all();
foreach ($posts as $post) {
    echo $post->user->name; // Executes query for each post
}

// Good: Eager Loading
$posts = Post::with('user', 'comments.user')->get();
foreach ($posts as $post) {
    echo $post->user->name; // No additional queries
    foreach ($post->comments as $comment) {
        echo $comment->user->name; // No additional queries
    }
}
```

### Selective Loading

```php
// Load specific columns
$users = User::select(['id', 'name', 'email'])->get();

// Load specific relationships with columns
$posts = Post::with([
    'user:id,name,email',
    'comments:id,post_id,user_id,content',
    'comments.user:id,name'
])->get();

// Lazy loading specific relationships
$post = Post::first();
$post->load(['user', 'comments' => function ($query) {
    $query->where('status', 'approved');
}]);
```

### Query Chunking

```php
// Process large datasets efficiently
User::chunk(200, function ($users) {
    foreach ($users as $user) {
        // Process user
    }
});

// Chunk with ID-based ordering for large tables
User::orderBy('id')->chunk(200, function ($users) {
    // Process chunk
});

// Chunk by ID directly (more memory efficient)
foreach (User::lazy() as $user) {
    // Process user
}
```

### Database Transactions

```php
use Illuminate\Support\Facades\DB;

try {
    DB::beginTransaction();

    // Create user
    $user = User::create([
        'name' => 'John Doe',
        'email' => 'john@example.com',
    ]);

    // Create profile
    $user->profile()->create([
        'bio' => 'Developer',
        'location' => 'USA',
    ]);

    // Send welcome email
    Mail::to($user->email)->send(new WelcomeEmail($user));

    DB::commit();
} catch (Exception $e) {
    DB::rollBack();
    Sentry::captureException($e);
    throw $e;
}
```

---

## Database Seeding

### Model Factories

```php
// database/factories/UserFactory.php
namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class UserFactory extends Factory
{
    protected $model = User::class;

    public function definition(): array
    {
        return [
            'first_name' => $this->faker->firstName(),
            'last_name' => $this->faker->lastName(),
            'email' => $this->faker->unique()->safeEmail(),
            'email_verified_at' => now(),
            'password' => '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', // password
            'phone' => $this->faker->phoneNumber(),
            'role' => $this->faker->randomElement(['user', 'admin']),
            'status' => 'active',
            'settings' => [
                'theme' => $this->faker->randomElement(['light', 'dark']),
                'notifications' => $this->faker->boolean(),
            ],
            'remember_token' => Str::random(10),
        ];
    }

    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }

    public function admin(): static
    {
        return $this->state(fn (array $attributes) => [
            'role' => 'admin',
        ]);
    }
}
```

### Database Seeder

```php
// database/seeders/DatabaseSeeder.php
namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            UserSeeder::class,
            CategorySeeder::class,
            PostSeeder::class,
            CommentSeeder::class,
        ]);
    }
}

// database/seeders/UserSeeder.php
class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Create admin user
        User::factory()->admin()->create([
            'email' => 'admin@example.com',
        ]);

        // Create regular users
        User::factory(50)->create();
    }
}
```

---

## Best Practices

### Model Guidelines

1. **Mass Assignment**: Always use $fillable
2. **Relationships**: Define all relationships explicitly
3. **Casting**: Cast attributes to proper types
4. **Scopes**: Use scopes for common queries
5. **Validation**: Validate at model or request level

### Query Optimization

1. **Eager Load**: Avoid N+1 problems
2. **Select Only Needed**: Don't select unnecessary columns
3. **Use Indexes**: Proper database indexing
4. **Chunk Large Queries**: Process data in batches
5. **Cache Results**: Cache expensive query results

### Database Design

1. **Normalization**: Proper table relationships
2. **Data Types**: Appropriate data types and constraints
3. **Indexing**: Strategic index placement
4. **Migration History**: Keep migrations clean and reversible
5. **Foreign Keys**: Use foreign key constraints