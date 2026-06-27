<?php

namespace App\Http\Controllers;

use App\Models\PortalService;
use App\Services\PortalServiceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PortalServiceController extends Controller
{
    public function __construct(
        protected PortalServiceService $service,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $services = $this->service->search(
            $request->input('search'),
            $request->has('is_active') ? $request->boolean('is_active') : null,
            $request->input('per_page', 15),
        );

        return response()->json([
            'success' => true,
            'data' => $services,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'service_code' => 'required|string|max:100|unique:portal_services,service_code',
            'service_name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'status' => 'required|string|max:100',
            'link' => 'nullable|string|max:500',
            'sort_order' => 'nullable|integer|min:0',
            'is_active' => 'nullable|boolean',
        ]);

        $portalService = $this->service->create($validated);

        return response()->json([
            'success' => true,
            'data' => $portalService,
            'message' => 'Portal service created successfully',
        ], 201);
    }

    public function show(PortalService $portalService): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => $portalService,
        ]);
    }

    public function update(Request $request, PortalService $portalService): JsonResponse
    {
        $validated = $request->validate([
            'service_code' => 'sometimes|required|string|max:100|unique:portal_services,service_code,' . $portalService->id,
            'service_name' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'status' => 'sometimes|required|string|max:100',
            'link' => 'nullable|string|max:500',
            'sort_order' => 'nullable|integer|min:0',
            'is_active' => 'nullable|boolean',
        ]);

        $updated = $this->service->update($portalService, $validated);

        return response()->json([
            'success' => true,
            'data' => $updated,
            'message' => 'Portal service updated successfully',
        ]);
    }

    public function destroy(PortalService $portalService): JsonResponse
    {
        $this->service->delete($portalService);

        return response()->json([
            'success' => true,
            'message' => 'Portal service deleted successfully',
        ]);
    }
}
