<?php

namespace App\Services;

use App\Models\PortalService;
use App\Repositories\PortalServiceRepository;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class PortalServiceService
{
    public function __construct(
        protected PortalServiceRepository $repository,
    ) {}

    public function search(?string $search, ?bool $isActive, int $perPage = 15): LengthAwarePaginator
    {
        return $this->repository->search($search, $isActive, $perPage);
    }

    public function find(int $id): ?PortalService
    {
        return $this->repository->find($id);
    }

    public function create(array $data): PortalService
    {
        return $this->repository->create($data);
    }

    public function update(PortalService $service, array $data): PortalService
    {
        return $this->repository->update($service, $data);
    }

    public function delete(PortalService $service): bool
    {
        return $this->repository->delete($service);
    }
}
