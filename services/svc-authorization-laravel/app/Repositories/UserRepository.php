<?php

namespace App\Repositories;

use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;

class UserRepository
{
    public function __construct(
        protected User $model,
    ) {}

    public function query(): Builder
    {
        return $this->model->with('roles');
    }

    public function search(?string $search, ?bool $isActive, int $perPage = 15): LengthAwarePaginator
    {
        $query = $this->model->with('roles');

        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                  ->orWhere('email', 'ilike', "%{$search}%")
                  ->orWhere('phone', 'ilike', "%{$search}%");
            });
        }

        if ($isActive !== null) {
            $query->where('is_active', $isActive);
        }

        return $query->orderBy('created_at', 'desc')->paginate($perPage);
    }

    public function find(int $id): ?User
    {
        return $this->model->with('roles.permissions')->find($id);
    }

    public function findByEmail(string $email): ?User
    {
        return $this->model->where('email', $email)->first();
    }

    public function create(array $data): User
    {
        return $this->model->create($data);
    }

    public function update(User $user, array $data): User
    {
        $user->update($data);
        return $user->fresh('roles');
    }

    public function delete(User $user): bool
    {
        return $user->delete();
    }
}
