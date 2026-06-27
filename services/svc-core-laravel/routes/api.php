<?php

use App\Http\Controllers\PlatformConfigController;
use App\Http\Controllers\PortalAppController;
use App\Http\Controllers\PortalCarouselSlideController;
use App\Http\Controllers\PortalServiceController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    // Portal Content
    Route::apiResource('portal/carousel-slides', PortalCarouselSlideController::class);
    Route::apiResource('portal/apps', PortalAppController::class);
    Route::apiResource('portal/services', PortalServiceController::class);

    // Platform Config (manual routes to use key string instead of model ID)
    Route::get('platform/configs', [PlatformConfigController::class, 'index']);
    Route::post('platform/configs', [PlatformConfigController::class, 'store']);
    Route::get('platform/configs/{key}', [PlatformConfigController::class, 'show']);
    Route::put('platform/configs/{key}', [PlatformConfigController::class, 'update']);
    Route::delete('platform/configs/{key}', [PlatformConfigController::class, 'destroy']);
});
