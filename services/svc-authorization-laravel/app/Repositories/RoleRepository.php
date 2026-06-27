<?php

namespace App\Repositories;

use Illuminate\Database\Eloquent\Collection;
use Spatie\Permission\Models\Role;

class RoleRepository
{
    public function __construct(
        protected Role $model,
    ) {}

    public function search(?string $search): Collection
    {
        $query = $this->model->with('permissions');

        if ($search) {
            $query->where('name', 'ilike', "%{$search}%");
        }

        return $query->orderBy('name')->get();
    }

    public function find(int $id): ?Role
    {
        return $this->model->with('permissions')->find($id);
    }

    public function findByName(string $name): ?Role
    {
        return $this->model->where('name', $name)->first();
    }

    public function create(array $data): Role
    {
        return $this->model->create($data);
    }

    public function update(Role $role, array $data): Role
    {
        $role->update($data);
        return $role->fresh('permissions');
    }

    public function delete(Role $role): bool
    {
        return $role->delete();
    }
}
