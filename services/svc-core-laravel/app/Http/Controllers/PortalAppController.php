<?php

namespace App\Http\Controllers;

use App\Models\PortalApp;
use App\Services\PortalAppService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PortalAppController extends Controller
{
    public function __construct(
        protected PortalAppService $service,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $apps = $this->service->search(
            $request->input('search'),
            $request->has('is_active') ? $request->boolean('is_active') : null,
            $request->input('per_page', 15),
        );

        return response()->json([
            'success' => true,
            'data' => $apps,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'app_name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'status' => 'required|string|max:100',
            'link' => 'nullable|string|max:500',
            'sort_order' => 'nullable|integer|min:0',
            'is_active' => 'nullable|boolean',
        ]);

        $app = $this->service->create($validated);

        return response()->json([
            'success' => true,
            'data' => $app,
            'message' => 'Portal app created successfully',
        ], 201);
    }

    public function show(PortalApp $portalApp): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => $portalApp,
        ]);
    }

    public function update(Request $request, PortalApp $portalApp): JsonResponse
    {
        $validated = $request->validate([
            'app_name' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'status' => 'sometimes|required|string|max:100',
            'link' => 'nullable|string|max:500',
            'sort_order' => 'nullable|integer|min:0',
            'is_active' => 'nullable|boolean',
        ]);

        $app = $this->service->update($portalApp, $validated);

        return response()->json([
            'success' => true,
            'data' => $app,
            'message' => 'Portal app updated successfully',
        ]);
    }

    public function destroy(PortalApp $portalApp): JsonResponse
    {
        $this->service->delete($portalApp);

        return response()->json([
            'success' => true,
            'message' => 'Portal app deleted successfully',
        ]);
    }
}
