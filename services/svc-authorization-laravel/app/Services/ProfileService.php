<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;

class ProfileService
{
    public function __construct(
        protected UserService $userService,
    ) {}

    public function show(User $user): array
    {
        $user->load('roles.permissions');

        return [
            'user' => $user,
            'roles' => $user->getRoleNames(),
            'permissions' => $user->getAllPermissions()->pluck('name'),
        ];
    }

    public function update(User $user, array $data): User
    {
        return $this->userService->update($user, $data);
    }

    public function updatePassword(User $user, string $currentPassword, string $newPassword): void
    {
        $this->userService->validateCredentials($user, $currentPassword);

        $user->update([
            'password' => Hash::make($newPassword),
        ]);
    }
}
