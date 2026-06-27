<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Services\UserService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rules\Password;

class UserController extends Controller
{
    public function __construct(
        protected UserService $service,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $perPage = min($request->input('per_page', 15), 100);
        $users = $this->service->search(
            $request->input('search'),
            $request->has('is_active') ? $request->boolean('is_active') : null,
            $perPage,
        );

        return response()->json([
            'success' => true,
            'data' => $users,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => ['required', 'confirmed', Password::min(8)->mixedCase()->numbers()],
            'phone' => 'sometimes|nullable|string|max:20',
            'timezone' => 'sometimes|nullable|string|max:50',
            'is_active' => 'sometimes|boolean',
            'roles' => 'sometimes|array',
            'roles.*' => 'string|exists:roles,name',
        ]);

        $user = $this->service->create($validated);

        return response()->json([
            'success' => true,
            'message' => 'User created successfully',
            'data' => [
                'user' => $user,
            ],
        ], 201);
    }

    public function show(User $user): JsonResponse
    {
        $user = $this->service->find($user->id);

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $user,
                'roles' => $user->getRoleNames(),
                'permissions' => $user->getAllPermissions()->pluck('name'),
            ],
        ]);
    }

    public function update(Request $request, User $user): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $user->id,
            'phone' => 'sometimes|nullable|string|max:20',
            'timezone' => 'sometimes|nullable|string|max:50',
            'is_active' => 'sometimes|boolean',
            'roles' => 'sometimes|array',
            'roles.*' => 'string|exists:roles,name',
        ]);

        $user = $this->service->update($user, $validated);

        return response()->json([
            'success' => true,
            'message' => 'User updated successfully',
            'data' => [
                'user' => $user,
            ],
        ]);
    }

    public function destroy(User $user): JsonResponse
    {
        $this->service->delete($user);

        return response()->json([
            'success' => true,
            'message' => 'User deleted successfully',
        ]);
    }

    public function assignRoles(Request $request, User $user): JsonResponse
    {
        $request->validate([
            'roles' => 'required|array',
            'roles.*' => 'string|exists:roles,name',
        ]);

        $user = $this->service->syncRoles($user, $request->input('roles'));

        return response()->json([
            'success' => true,
            'message' => 'Roles assigned successfully',
            'data' => [
                'roles' => $user->getRoleNames(),
            ],
        ]);
    }

    public function removeRoles(Request $request, User $user): JsonResponse
    {
        $request->validate([
            'roles' => 'required|array',
            'roles.*' => 'string|exists:roles,name',
        ]);

        $user = $this->service->removeRoles($user, $request->input('roles'));

        return response()->json([
            'success' => true,
            'message' => 'Roles removed successfully',
            'data' => [
                'roles' => $user->getRoleNames(),
            ],
        ]);
    }

    public function assignPermissions(Request $request, User $user): JsonResponse
    {
        $request->validate([
            'permissions' => 'required|array',
            'permissions.*' => 'string|exists:permissions,name',
        ]);

        $user = $this->service->syncPermissions($user, $request->input('permissions'));

        return response()->json([
            'success' => true,
            'message' => 'Permissions assigned successfully',
            'data' => [
                'permissions' => $user->getAllPermissions()->pluck('name'),
            ],
        ]);
    }

    public function removePermissions(Request $request, User $user): JsonResponse
    {
        $request->validate([
            'permissions' => 'required|array',
            'permissions.*' => 'string|exists:permissions,name',
        ]);

        $user = $this->service->revokePermissions($user, $request->input('permissions'));

        return response()->json([
            'success' => true,
            'message' => 'Permissions removed successfully',
            'data' => [
                'permissions' => $user->getAllPermissions()->pluck('name'),
            ],
        ]);
    }
}
