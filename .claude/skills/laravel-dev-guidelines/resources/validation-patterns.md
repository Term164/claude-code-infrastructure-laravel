# Laravel Validation Patterns

## Form Request Validation

### Creating Form Requests

```bash
php artisan make:request StoreUserRequest
php artisan make:request UpdateUserRequest
```

### StoreUserRequest Example

```php
// app/Http/Requests/StoreUserRequest.php
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\Rules\Unique;

class StoreUserRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request
     */
    public function authorize(): bool
    {
        return true; // Or implement authorization logic
        // return $this->user()->can('create', User::class);
    }

    /**
     * Get the validation rules that apply to the request
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => [
                'required',
                'string',
                'email:rfc,dns',
                'max:255',
                new Unique(User::class),
            ],
            'password' => [
                'required',
                'confirmed',
                Password::min(8)
                    ->letters()
                    ->mixedCase()
                    ->numbers()
                    ->symbols(),
            ],
            'phone' => ['nullable', 'string', 'regex:/^[+]?[1-9]\d{1,14}$/'],
            'avatar' => ['nullable', 'image', 'mimes:jpeg,png,jpg,gif', 'max:2048'],
            'role' => ['required', 'string', 'exists:roles,name'],
            'settings' => ['array'],
            'settings.notifications' => ['boolean'],
            'settings.theme' => ['string', 'in:light,dark,auto'],
        ];
    }

    /**
     * Get custom error messages
     */
    public function messages(): array
    {
        return [
            'name.required' => 'Your name is required',
            'email.unique' => 'This email is already registered',
            'password.letters' => 'Password must contain at least one letter',
            'password.symbols' => 'Password must contain at least one symbol',
            'avatar.max' => 'Avatar size must be less than 2MB',
        ];
    }

    /**
     * Get custom attributes for validator errors
     */
    public function attributes(): array
    {
        return [
            'phone' => 'phone number',
            'avatar' => 'profile picture',
        ];
    }

    /**
     * Prepare the data for validation
     */
    protected function prepareForValidation(): void
    {
        $this->merge([
            'phone' => preg_replace('/[^0-9+]/', '', $this->phone ?? ''),
        ]);
    }
}
```

### UpdateUserRequest Example

```php
// app/Http/Requests/UpdateUserRequest.php
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->id === $this->route('user')->id
            || $this->user()->can('update', $this->route('user'));
    }

    public function rules(): array
    {
        $userId = $this->route('user')->id;

        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => [
                'sometimes',
                'string',
                'email:rfc,dns',
                'max:255',
                Rule::unique(User::class)->ignore($userId),
            ],
            'password' => [
                'sometimes',
                'confirmed',
                'min:8',
                'regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/',
            ],
            'avatar' => ['nullable', 'image', 'mimes:jpeg,png,jpg', 'max:1024'],
            'preferences' => ['array'],
            'preferences.timezone' => ['string', 'timezone'],
            'preferences.language' => ['string', 'in:en,es,fr,de,it'],
        ];
    }
}
```

---

## Advanced Validation Patterns

### Conditional Validation

```php
public function rules(): array
{
    return [
        'type' => ['required', 'in:individual,company'],
        'company_name' => [
            'required_if:type,company',
            'string',
            'max:255',
        ],
        'tax_id' => [
            'required_if:type,company',
            'string',
            'regex:/^[A-Z0-9]{10,20}$/',
        ],
        'birth_date' => [
            'required_if:type,individual',
            'date',
            'before:' . now()->subYears(18)->format('Y-m-d'),
        ],
    ];
}
```

### Array and Nested Validation

```php
public function rules(): array
{
    return [
        'products' => ['required', 'array', 'min:1', 'max:10'],
        'products.*.id' => ['required', 'exists:products,id'],
        'products.*.quantity' => ['required', 'integer', 'min:1', 'max:100'],
        'products.*.variants' => ['array'],
        'products.*.variants.color' => ['string', 'in:red,blue,green'],
        'products.*.variants.size' => ['string', 'in:small,medium,large'],
        'shipping_address' => ['required', 'array'],
        'shipping_address.street' => ['required', 'string'],
        'shipping_address.city' => ['required', 'string'],
        'shipping_address.country' => ['required', 'string', 'size:2'],
    ];
}
```

### Custom Validation Rules

```php
// app/Rules/ValidPassword.php
namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

class ValidPassword implements ValidationRule
{
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (!preg_match('/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/', $value)) {
            $fail('The :attribute must contain uppercase, lowercase, number, and special character.');
        }
    }
}

// Usage in Form Request
public function rules(): array
{
    return [
        'password' => ['required', new ValidPassword()],
    ];
}
```

---

## Validation in Controllers

### Manual Validation

```php
public function store(Request $request): JsonResponse
{
    $validated = $request->validate([
        'name' => 'required|string|max:255',
        'email' => 'required|email|unique:users',
    ]);

    // Handle successful validation
    return $this->successResponse($validated);
}
```

### Custom Validation Response

```php
public function store(Request $request): JsonResponse
{
    $validator = Validator::make($request->all(), [
        'name' => 'required|string|max:255',
        'email' => 'required|email|unique:users',
    ]);

    if ($validator->fails()) {
        return $this->validationErrorResponse(
            $validator->errors()->toArray()
        );
    }

    // Continue with valid data
    $validated = $validator->validated();
    // ...
}
```

---

## API Resource Validation

### Request Validation for APIs

```php
// app/Http/Requests/Api/CreateOrderRequest.php
class CreateOrderRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'customer_id' => ['required', 'exists:customers,id'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.quantity' => ['required', 'integer', 'min:1'],
            'items.*.price' => ['required', 'numeric', 'min:0'],
            'shipping' => ['array'],
            'shipping.method' => ['required', 'string', 'in:standard,express'],
            'shipping.address' => ['required', 'array'],
            'shipping.address.line1' => ['required', 'string'],
            'shipping.address.city' => ['required', 'string'],
            'shipping.address.postal_code' => ['required', 'string'],
            'shipping.address.country' => ['required', 'string', 'size:2'],
            'coupon_code' => ['nullable', 'string', 'exists:coupons,code,active,1'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }

    /**
     * Validate coupon if provided
     */
    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            if ($this->has('coupon_code')) {
                $coupon = Coupon::where('code', $this->coupon_code)->first();

                if ($coupon && !$coupon->isValidForAmount($this->getTotalAmount())) {
                    $validator->errors()->add('coupon_code', 'Coupon is not valid for this order amount');
                }
            }
        });
    }

    private function getTotalAmount(): float
    {
        return collect($this->input('items', []))
            ->sum(fn ($item) => $item['price'] * $item['quantity']);
    }
}
```

---

## File Upload Validation

### Image Upload Validation

```php
public function rules(): array
{
    return [
        'avatar' => [
            'required',
            'image',
            'mimes:jpeg,png,jpg,gif,webp',
            'max:2048', // 2MB
            'dimensions:min_width=100,min_height=100,max_width=2000,max_height=2000',
        ],
        'documents' => ['array', 'max:5'],
        'documents.*' => [
            'file',
            'mimes:pdf,doc,docx,txt',
            'max:5120', // 5MB
        ],
        'cover_image' => [
            'nullable',
            'image',
            'mimes:jpeg,png',
            'dimensions:ratio=16/9',
        ],
    ];
}
```

### Custom File Validation

```php
// app/Rules/ImageDimensions.php
class ImageDimensions implements ValidationRule
{
    public function __construct(
        private int $minWidth,
        private int $minHeight,
        private ?int $maxWidth = null,
        private ?int $maxHeight = null
    ) {}

    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (!$value instanceof \Illuminate\Http\UploadedFile) {
            return;
        }

        $imageInfo = getimagesize($value->getPathname());

        if (!$imageInfo) {
            $fail('The :attribute must be a valid image file.');
            return;
        }

        [$width, $height] = $imageInfo;

        if ($width < $this->minWidth || $height < $this->minHeight) {
            $fail("The :attribute must be at least {$this->minWidth}x{$this->minHeight} pixels.");
        }

        if ($this->maxWidth && $width > $this->maxWidth) {
            $fail("The :attribute cannot be wider than {$this->maxWidth} pixels.");
        }

        if ($this->maxHeight && $height > $this->maxHeight) {
            $fail("The :attribute cannot be taller than {$this->maxHeight} pixels.");
        }
    }
}
```

---

## Validation Best Practices

### General Guidelines

1. **Use Form Requests**: For complex validation logic
2. **Be Specific**: Clear validation rules and messages
3. **Validate Early**: Validate as soon as possible
4. **Handle Files**: Use proper file validation rules
5. **Provide Context**: Custom error messages help users

### Security Considerations

1. **Sanitize Input**: Use prepareForValidation() for cleaning data
2. **Validate File Types**: Always validate file mime types and sizes
3. **Check Origins**: Validate URLs and external references
4. **Rate Limit**: Protect against brute force attacks
5. **CSRF Protection**: Use CSRF tokens for stateful requests

### Performance Optimization

1. **Batch Validation**: Validate arrays efficiently
2. **Conditional Rules**: Use when() for conditional validation
3. **Custom Rules**: Reuse validation logic
4. **Early Returns**: Fail fast on critical errors
5. **Cache Results**: Cache expensive validation checks