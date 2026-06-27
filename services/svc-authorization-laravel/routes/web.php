<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'service' => 'RASHA Authorization Service',
        'version' => '1.0.0',
        'status' => 'running',
    ]);
});
