<?php

use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Auth\ProfileController;
use App\Http\Controllers\PermissionController;
use App\Http\Controllers\RoleController;
use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Authentication Routes (Public)
|--------------------------------------------------------------------------
*/
Route::prefix('v1/auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
});

/*
|--------------------------------------------------------------------------
| Protected Routes (Require Sanctum Token)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->prefix('v1')->group(function () {

    // Auth
    Route::post('auth/logout', [AuthController::class, 'logout']);
    Route::get('auth/me', [AuthController::class, 'me']);

    // Profile
    Route::get('profile', [ProfileController::class, 'show']);
    Route::put('profile', [ProfileController::class, 'update']);
    Route::put('profile/password', [ProfileController::class, 'updatePassword']);

    // Users (Admin)
    Route::apiResource('users', UserController::class)->except(['create', 'edit']);

    // Roles (Admin)
    Route::apiResource('roles', RoleController::class)->except(['create', 'edit']);

    // Permissions (Admin)
    Route::apiResource('permissions', PermissionController::class)->except(['create', 'edit']);

    // User-Role assignment
    Route::post('users/{user}/roles', [UserController::class, 'assignRoles']);
    Route::delete('users/{user}/roles', [UserController::class, 'removeRoles']);

    // User-Permission assignment
    Route::post('users/{user}/permissions', [UserController::class, 'assignPermissions']);
    Route::delete('users/{user}/permissions', [UserController::class, 'removePermissions']);

    // Role-Permission assignment
    Route::post('roles/{role}/permissions', [RoleController::class, 'assignPermissions']);
    Route::delete('roles/{role}/permissions', [RoleController::class, 'removePermissions']);
});
