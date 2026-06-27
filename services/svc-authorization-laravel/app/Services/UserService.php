<?php

namespace App\Services;

use App\Models\User;
use App\Repositories\UserRepository;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class UserService
{
    public function __construct(
        protected UserRepository $repository,
    ) {}

    public function search(?string $search, ?bool $isActive, int $perPage = 15): LengthAwarePaginator
    {
        return $this->repository->search($search, $isActive, $perPage);
    }

    public function find(int $id): ?User
    {
        return $this->repository->find($id);
    }

    public function findByEmail(string $email): ?User
    {
        return $this->repository->findByEmail($email);
    }

    public function create(array $data): User
    {
        $data['password'] = Hash::make($data['password']);
        $user = $this->repository->create($data);

        if (! empty($data['roles'])) {
            $user->syncRoles($data['roles']);
        }

        return $user->fresh('roles');
    }

    public function update(User $user, array $data): User
    {
        $user = $this->repository->update($user, $data);

        if (array_key_exists('roles', $data)) {
            $user->syncRoles($data['roles']);
        }

        return $user->fresh('roles');
    }

    public function delete(User $user): bool
    {
        return $this->repository->delete($user);
    }

    public function syncRoles(User $user, array $roles): User
    {
        $user->syncRoles($roles);
        return $user->fresh('roles');
    }

    public function removeRoles(User $user, array $roles): User
    {
        $user->removeRoles($roles);
        return $user->fresh('roles');
    }

    public function syncPermissions(User $user, array $permissions): User
    {
        $user->syncPermissions($permissions);
        return $user;
    }

    public function revokePermissions(User $user, array $permissions): User
    {
        $user->revokePermissionTo($permissions);
        return $user;
    }

    public function updateLoginInfo(User $user, ?string $ip): void
    {
        $user->update([
            'last_login_at' => now(),
            'last_login_ip' => $ip,
        ]);
    }

    public function validateCredentials(User $user, string $password): void
    {
        if (! Hash::check($password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        if (! $user->is_active) {
            throw ValidationException::withMessages([
                'email' => ['Your account has been deactivated.'],
            ]);
        }
    }
}
