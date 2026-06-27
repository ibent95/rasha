<?php

namespace Database\Seeders;

use App\Models\PlatformConfig;
use Illuminate\Database\Seeder;

class PlatformConfigSeeder extends Seeder
{
    public function run(): void
    {
        $configs = [
            [
                'key' => 'app_name',
                'value' => 'RASHA',
                'type' => 'string',
            ],
            [
                'key' => 'app_tagline',
                'value' => 'Integrated Business Management Platform',
                'type' => 'string',
            ],
            [
                'key' => 'app_version',
                'value' => '1.0.0',
                'type' => 'string',
            ],
            [
                'key' => 'maintenance_mode',
                'value' => 'false',
                'type' => 'boolean',
            ],
            [
                'key' => 'registration_enabled',
                'value' => 'true',
                'type' => 'boolean',
            ],
            [
                'key' => 'max_upload_size_mb',
                'value' => '10',
                'type' => 'integer',
            ],
            [
                'key' => 'supported_currencies',
                'value' => '["IDR","USD"]',
                'type' => 'json',
            ],
            [
                'key' => 'default_currency',
                'value' => 'IDR',
                'type' => 'string',
            ],
            [
                'key' => 'social_links',
                'value' => '{"website":"https://ibent95.my.id","github":"https://github.com/ibent95","linkedin":"https://linkedin.com/in/ibent95","instagram":"https://instagram.com/ibent95"}',
                'type' => 'json',
            ],
            [
                'key' => 'contact_email',
                'value' => 'admin@ibent95.my.id',
                'type' => 'string',
            ],
            [
                'key' => 'timezone',
                'value' => 'Asia/Jakarta',
                'type' => 'string',
            ],
            [
                'key' => 'date_format',
                'value' => 'd-m-Y',
                'type' => 'string',
            ],
            [
                'key' => 'items_per_page',
                'value' => '15',
                'type' => 'integer',
            ],
        ];

        foreach ($configs as $config) {
            PlatformConfig::create($config);
        }
    }
}
