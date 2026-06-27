<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class PortalCarouselSlide extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'portal_carousel_slides';

    protected $fillable = [
        'title',
        'description',
        'image_path',
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
