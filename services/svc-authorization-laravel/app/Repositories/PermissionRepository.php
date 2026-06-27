<?php

namespace App\Repositories;

use Spatie\Permission\Models\Permission;

class PermissionRepository
{
    public function __construct(
        protected Permission $model,
    ) {}

    public function search(?string $search, ?string $group): array
    {
        $query = $this->model->query();

        if ($search) {
            $query->where('name', 'ilike', "%{$search}%");
        }

        if ($group) {
            $query->where('name', 'like', "{$group}.%");
        }

        $permissions = $query->orderBy('name')->get();

        $grouped = $permissions->groupBy(function ($permission) {
            $parts = explode('.', $permission->name);
            return $parts[0] ?? $permission->name;
        });

        return [
            'permissions' => $permissions->toArray(),
            'grouped' => $grouped->toArray(),
        ];
    }

    public function find(int $id): ?Permission
    {
        return $this->model->find($id);
    }

    public function create(array $data): Permission
    {
        return $this->model->create($data);
    }

    public function update(Permission $permission, array $data): Permission
    {
        $permission->update($data);
        return $permission->fresh();
    }

    public function delete(Permission $permission): bool
    {
        return $permission->delete();
    }
}
