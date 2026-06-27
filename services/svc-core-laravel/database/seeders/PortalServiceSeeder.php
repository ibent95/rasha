<?php

namespace Database\Seeders;

use App\Models\PortalService;
use Illuminate\Database\Seeder;

class PortalServiceSeeder extends Seeder
{
    public function run(): void
    {
        $services = [
            [
                'service_code' => 'CORE',
                'service_name' => 'Core Service',
                'description' => 'Portal content management, platform configuration, and shared infrastructure APIs.',
                'status' => 'active',
                'link' => null,
                'sort_order' => 1,
                'is_active' => true,
            ],
            [
                'service_code' => 'CRM',
                'service_name' => 'CRM Service',
                'description' => 'Customer management, lead tracking, and sales pipeline APIs.',
                'status' => 'active',
                'link' => '/api/v1/crm',
                'sort_order' => 2,
                'is_active' => true,
            ],
            [
                'service_code' => 'ERP',
                'service_name' => 'ERP Service',
                'description' => 'Inventory, warehouse, supplier, and financial transaction APIs.',
                'status' => 'active',
                'link' => '/api/v1/erp',
                'sort_order' => 3,
                'is_active' => true,
            ],
            [
                'service_code' => 'DYNFORM',
                'service_name' => 'Dynamic Form Service',
                'description' => 'Form builder, submission handling, and response analytics APIs.',
                'status' => 'active',
                'link' => '/api/v1/dynamic-form',
                'sort_order' => 4,
                'is_active' => true,
            ],
            [
                'service_code' => 'AUTH',
                'service_name' => 'Authorization Service',
                'description' => 'User authentication, role management, and permission APIs.',
                'status' => 'active',
                'link' => '/api/v1/auth',
                'sort_order' => 5,
                'is_active' => true,
            ],
        ];

        foreach ($services as $service) {
            PortalService::create($service);
        }
    }
}
