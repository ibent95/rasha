<?php

namespace App\Services;

use App\Repositories\RoleRepository;
use Illuminate\Database\Eloquent\Collection;
use Spatie\Permission\Models\Role;

class RoleService
{
    public function __construct(
        protected RoleRepository $repository,
    ) {}

    public function search(?string $search): Collection
    {
        return $this->repository->search($search);
    }

    public function find(int $id): ?Role
    {
        return $this->repository->find($id);
    }

    public function findByName(string $name): ?Role
    {
        return $this->repository->findByName($name);
    }

    public function create(array $data): Role
    {
        $role = $this->repository->create($data);

        if (! empty($data['permissions'])) {
            $role->syncPermissions($data['permissions']);
        }

        return $role->fresh('permissions');
    }

    public function update(Role $role, array $data): Role
    {
        return $this->repository->update($role, $data);
    }

    public function delete(Role $role): bool
    {
        if ($role->name === 'super-admin') {
            return false;
        }

        return $this->repository->delete($role);
    }

    public function syncPermissions(Role $role, array $permissions): Role
    {
        $role->syncPermissions($permissions);
        return $role->fresh('permissions');
    }

    public function revokePermissions(Role $role, array $permissions): Role
    {
        $role->revokePermissionTo($permissions);
        return $role->fresh('permissions');
    }
}
