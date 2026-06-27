<?php

namespace App\Http\Controllers;

use App\Services\PermissionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Spatie\Permission\Models\Permission;

class PermissionController extends Controller
{
    public function __construct(
        protected PermissionService $service,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $result = $this->service->search(
            $request->input('search'),
            $request->input('group'),
        );

        return response()->json([
            'success' => true,
            'data' => $result,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255|unique:permissions,name',
            'guard_name' => 'sometimes|string|max:255',
        ]);

        $permission = $this->service->create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Permission created successfully',
            'data' => [
                'permission' => $permission,
            ],
        ], 201);
    }

    public function show(Permission $permission): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'permission' => $permission,
                'roles_count' => $permission->roles()->count(),
            ],
        ]);
    }

    public function update(Request $request, Permission $permission): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255|unique:permissions,name,' . $permission->id,
        ]);

        $permission = $this->service->update($permission, $validated);

        return response()->json([
            'success' => true,
            'message' => 'Permission updated successfully',
            'data' => [
                'permission' => $permission,
            ],
        ]);
    }

    public function destroy(Permission $permission): JsonResponse
    {
        $this->service->delete($permission);

        return response()->json([
            'success' => true,
            'message' => 'Permission deleted successfully',
        ]);
    }
}
