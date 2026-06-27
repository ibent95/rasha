<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class PortalService extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'portal_services';

    protected $fillable = [
        'service_code',
        'service_name',
        'description',
        'status',
        'link',
        'sort_order',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'sort_order' => 'integer',
            'is_active' => 'boolean',
        ];
    }
}
