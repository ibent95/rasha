<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        /*
        |--------------------------------------------------------------------------
        | Permissions
        |--------------------------------------------------------------------------
        | Convention: {resource}.{action} (e.g., users.create, roles.delete)
        */
        $resources = [
            'users' => ['view', 'create', 'update', 'delete'],
            'roles' => ['view', 'create', 'update', 'delete'],
            'permissions' => ['view', 'create', 'update', 'delete'],
            'portal-apps' => ['view', 'create', 'update', 'delete'],
            'portal-carousel' => ['view', 'create', 'update', 'delete'],
            'portal-services' => ['view', 'create', 'update', 'delete'],
            'platform-configs' => ['view', 'update'],
        ];

        foreach ($resources as $resource => $actions) {
            foreach ($actions as $action) {
                Permission::firstOrCreate(['name' => "{$resource}.{$action}"]);
            }
        }

        /*
        |--------------------------------------------------------------------------
        | Roles
        |--------------------------------------------------------------------------
        */
        $superAdmin = Role::firstOrCreate(['name' => 'super-admin']);
        $superAdmin->syncPermissions(Permission::all());

        $admin = Role::firstOrCreate(['name' => 'admin']);
        $admin->syncPermissions(
            Permission::where(function ($q) {
                $q->whereIn('name', [
                    'users.view', 'users.create', 'users.update',
                    'roles.view',
                    'permissions.view',
                ])->orWhere('name', 'like', 'portal-apps.%')
                  ->orWhere('name', 'like', 'portal-carousel.%')
                  ->orWhere('name', 'like', 'portal-services.%')
                  ->orWhere('name', 'like', 'platform-configs.%');
            })->get()
        );

        $editor = Role::firstOrCreate(['name' => 'editor']);
        $editor->syncPermissions([
            'portal-apps.view', 'portal-apps.update',
            'portal-carousel.view', 'portal-carousel.update',
            'portal-services.view', 'portal-services.update',
            'platform-configs.view', 'platform-configs.update',
        ]);

        $viewer = Role::firstOrCreate(['name' => 'viewer']);
        $viewer->syncPermissions([
            'portal-apps.view',
            'portal-carousel.view',
            'portal-services.view',
            'platform-configs.view',
        ]);

        /*
        |--------------------------------------------------------------------------
        | Default Super Admin User
        |--------------------------------------------------------------------------
        */
        User::firstOrCreate(
            ['email' => 'admin@rasha.local'],
            [
                'name' => 'Super Admin',
                'password' => Hash::make('password'),
                'is_active' => true,
                'email_verified_at' => now(),
            ]
        )->assignRole('super-admin');
    }
}
