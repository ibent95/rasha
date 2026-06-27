<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PlatformConfig extends Model
{
    protected $table = 'platform_configs';

    protected $fillable = [
        'key',
        'value',
        'type',
    ];

    public static function get(string $key, mixed $default = null): mixed
    {
        $config = static::where('key', $key)->first();

        if (!$config) {
            return $default;
        }

        return match ($config->type) {
            'json' => json_decode($config->value, true),
            'boolean' => filter_var($config->value, FILTER_VALIDATE_BOOLEAN),
            'integer' => (int) $config->value,
            'float' => (float) $config->value,
            default => $config->value,
        };
    }

    public static function set(string $key, mixed $value, string $type = 'string'): static
    {
        return static::updateOrCreate(
            ['key' => $key],
            ['value' => is_array($value) ? json_encode($value) : (string) $value, 'type' => $type]
        );
    }
}
