<?php

namespace Database\Seeders;

use App\Models\PortalApp;
use Illuminate\Database\Seeder;

class PortalAppSeeder extends Seeder
{
    public function run(): void
    {
        $apps = [
            [
                'app_name' => 'CRM',
                'description' => 'Customer Relationship Management — manage leads, contacts, and sales pipeline.',
                'status' => 'active',
                'link' => '/crm',
                'sort_order' => 1,
                'is_active' => true,
            ],
            [
                'app_name' => 'ERP',
                'description' => 'Enterprise Resource Planning — inventory, finance, and supply chain in one place.',
                'status' => 'active',
                'link' => '/erp',
                'sort_order' => 2,
                'is_active' => true,
            ],
            [
                'app_name' => 'Dynamic Form',
                'description' => 'Custom form builder — create, distribute, and analyze forms effortlessly.',
                'status' => 'active',
                'link' => '/dynamic-form',
                'sort_order' => 3,
                'is_active' => true,
            ],
            [
                'app_name' => 'HR Management',
                'description' => 'Human resources — employee records, attendance, and payroll management.',
                'status' => 'coming_soon',
                'link' => null,
                'sort_order' => 4,
                'is_active' => false,
            ],
            [
                'app_name' => 'Project Management',
                'description' => 'Plan, track, and deliver projects on time with team collaboration tools.',
                'status' => 'coming_soon',
                'link' => null,
                'sort_order' => 5,
                'is_active' => false,
            ],
        ];

        foreach ($apps as $app) {
            PortalApp::create($app);
        }
    }
}
