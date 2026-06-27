<?php

namespace App\Http\Controllers;

use App\Services\PlatformConfigService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PlatformConfigController extends Controller
{
    public function __construct(
        protected PlatformConfigService $service,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $configs = $this->service->paginate($request->input('per_page', 50));

        return response()->json([
            'success' => true,
            'data' => $configs,
        ]);
    }

    public function show(string $key): JsonResponse
    {
        $config = $this->service->findByKey($key);

        if (! $config) {
            return response()->json(['success' => false, 'message' => 'Config not found'], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $config,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'key' => 'required|string|max:255|unique:platform_configs,key',
            'value' => 'nullable|string',
            'type' => 'required|string|in:string,json,boolean,integer,float',
        ]);

        $config = $this->service->create($validated);

        return response()->json([
            'success' => true,
            'data' => $config,
            'message' => 'Platform config created successfully',
        ], 201);
    }

    public function update(Request $request, string $key): JsonResponse
    {
        $config = $this->service->findByKey($key);

        if (! $config) {
            return response()->json(['success' => false, 'message' => 'Config not found'], 404);
        }

        $validated = $request->validate([
            'value' => 'nullable|string',
            'type' => 'sometimes|required|string|in:string,json,boolean,integer,float',
        ]);

        $config = $this->service->update($config, $validated);

        return response()->json([
            'success' => true,
            'data' => $config,
            'message' => 'Platform config updated successfully',
        ]);
    }

    public function destroy(string $key): JsonResponse
    {
        $config = $this->service->findByKey($key);

        if (! $config) {
            return response()->json(['success' => false, 'message' => 'Config not found'], 404);
        }

        $this->service->delete($config);

        return response()->json([
            'success' => true,
            'message' => 'Platform config deleted successfully',
        ]);
    }
}
