<?php

namespace Database\Seeders;

use App\Models\PortalCarouselSlide;
use Illuminate\Database\Seeder;

class PortalCarouselSlideSeeder extends Seeder
{
    public function run(): void
    {
        $slides = [
            [
                "title" => "Welcome to RASHA Platform",
                "description" =>
                    "Your integrated business management solution for seamless operations across ERP, CRM, and more.",
                "image_path" => "images/carousel/welcome-rasha.svg",
                "link" => null,
                "sort_order" => 1,
                "is_active" => true,
            ],
            [
                "title" => "Streamline Your Sales",
                "description" =>
                    "Manage leads, track opportunities, and close deals faster with RASHA CRM.",
                "image_path" => "images/carousel/crm-sales.svg",
                "link" => "/crm",
                "sort_order" => 2,
                "is_active" => true,
            ],
            [
                "title" => "Powerful ERP Features",
                "description" =>
                    "Inventory management, financial reporting, and supply chain optimization at your fingertips.",
                "image_path" => "images/carousel/erp-features.svg",
                "link" => "/erp",
                "sort_order" => 3,
                "is_active" => true,
            ],
            [
                "title" => "Dynamic Forms for Every Need",
                "description" =>
                    "Create custom forms, collect data, and automate workflows with our dynamic form builder.",
                "image_path" => "images/carousel/dynamic-forms.svg",
                "link" => "/dynamic-form",
                "sort_order" => 4,
                "is_active" => true,
            ],
            [
                "title" => "Mobile Ready",
                "description" =>
                    "Access RASHA from anywhere. Fully responsive design for all your devices.",
                "image_path" => "images/carousel/mobile-ready.svg",
                "link" => null,
                "sort_order" => 5,
                "is_active" => false,
            ],
        ];

        foreach ($slides as $slide) {
            PortalCarouselSlide::create($slide);
        }
    }
}
