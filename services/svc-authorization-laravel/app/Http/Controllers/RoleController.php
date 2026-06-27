<?php

namespace App\Http\Controllers;

use App\Services\RoleService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Spatie\Permission\Models\Role;

class RoleController extends Controller
{
    public function __construct(
        protected RoleService $service,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $roles = $this->service->search($request->input('search'));

        return response()->json([
            'success' => true,
            'data' => [
                'roles' => $roles,
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255|unique:roles,name',
            'permissions' => 'sometimes|array',
            'permissions.*' => 'string|exists:permissions,name',
        ]);

        $role = $this->service->create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Role created successfully',
            'data' => [
                'role' => $role,
            ],
        ], 201);
    }

    public function show(Role $role): JsonResponse
    {
        $role->load('permissions');

        return response()->json([
            'success' => true,
            'data' => [
                'role' => $role,
                'users_count' => $role->users()->count(),
            ],
        ]);
    }

    public function update(Request $request, Role $role): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255|unique:roles,name,' . $role->id,
        ]);

        $role = $this->service->update($role, $validated);

        return response()->json([
            'success' => true,
            'message' => 'Role updated successfully',
            'data' => [
                'role' => $role,
            ],
        ]);
    }

    public function destroy(Role $role): JsonResponse
    {
        if (! $this->service->delete($role)) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot delete the super-admin role',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'message' => 'Role deleted successfully',
        ]);
    }

    public function assignPermissions(Request $request, Role $role): JsonResponse
    {
        $request->validate([
            'permissions' => 'required|array',
            'permissions.*' => 'string|exists:permissions,name',
        ]);

        $role = $this->service->syncPermissions($role, $request->input('permissions'));

        return response()->json([
            'success' => true,
            'message' => 'Permissions assigned to role successfully',
            'data' => [
                'permissions' => $role->permissions->pluck('name'),
            ],
        ]);
    }

    public function removePermissions(Request $request, Role $role): JsonResponse
    {
        $request->validate([
            'permissions' => 'required|array',
            'permissions.*' => 'string|exists:permissions,name',
        ]);

        $role = $this->service->revokePermissions($role, $request->input('permissions'));

        return response()->json([
            'success' => true,
            'message' => 'Permissions removed from role successfully',
            'data' => [
                'permissions' => $role->permissions->pluck('name'),
            ],
        ]);
    }
}
