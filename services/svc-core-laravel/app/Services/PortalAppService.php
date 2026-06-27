<?php

namespace App\Services;

use App\Models\PortalApp;
use App\Repositories\PortalAppRepository;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class PortalAppService
{
    public function __construct(
        protected PortalAppRepository $repository,
    ) {}

    public function search(?string $search, ?bool $isActive, int $perPage = 15): LengthAwarePaginator
    {
        return $this->repository->search($search, $isActive, $perPage);
    }

    public function find(int $id): ?PortalApp
    {
        return $this->repository->find($id);
    }

    public function create(array $data): PortalApp
    {
        return $this->repository->create($data);
    }

    public function update(PortalApp $app, array $data): PortalApp
    {
        return $this->repository->update($app, $data);
    }

    public function delete(PortalApp $app): bool
    {
        return $this->repository->delete($app);
    }
}
