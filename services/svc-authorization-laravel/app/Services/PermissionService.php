<?php

namespace App\Services;

use App\Repositories\PermissionRepository;
use Spatie\Permission\Models\Permission;

class PermissionService
{
    public function __construct(
        protected PermissionRepository $repository,
    ) {}

    public function search(?string $search, ?string $group): array
    {
        return $this->repository->search($search, $group);
    }

    public function find(int $id): ?Permission
    {
        return $this->repository->find($id);
    }

    public function create(array $data): Permission
    {
        return $this->repository->create($data);
    }

    public function update(Permission $permission, array $data): Permission
    {
        return $this->repository->update($permission, $data);
    }

    public function delete(Permission $permission): bool
    {
        return $this->repository->delete($permission);
    }
}
