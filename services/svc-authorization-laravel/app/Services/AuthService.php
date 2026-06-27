<?php

namespace App\Services;

use App\Models\User;

class AuthService
{
    public function __construct(
        protected UserService $userService,
    ) {}

    public function register(array $data): array
    {
        $data['is_active'] = true;

        $user = $this->userService->create($data);
        $token = $user->createToken('auth-token')->plainTextToken;

        return [
            'user' => $user,
            'token' => $token,
        ];
    }

    public function login(User $user, string $password, ?string $ip): array
    {
        $this->userService->validateCredentials($user, $password);
        $this->userService->updateLoginInfo($user, $ip);

        $user->tokens()->delete();
        $token = $user->createToken('auth-token')->plainTextToken;

        return [
            'user' => $user,
            'token' => $token,
        ];
    }

    public function logout(User $user): void
    {
        $user->currentAccessToken()->delete();
    }

    public function me(User $user): array
    {
        $user->load('roles.permissions');

        return [
            'user' => $user,
            'roles' => $user->getRoleNames(),
            'permissions' => $user->getAllPermissions()->pluck('name'),
        ];
    }
}
