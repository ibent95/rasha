<?php

namespace App\Repositories;

use App\Models\PortalService;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class PortalServiceRepository
{
    public function __construct(
        protected PortalService $model,
    ) {}

    public function search(?string $search, ?bool $isActive, int $perPage = 15): LengthAwarePaginator
    {
        $query = $this->model->query();

        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('service_name', 'like', "%{$search}%")
                  ->orWhere('service_code', 'like', "%{$search}%");
            });
        }

        if ($isActive !== null) {
            $query->where('is_active', $isActive);
        }

        return $query->orderBy('sort_order')->paginate($perPage);
    }

    public function find(int $id): ?PortalService
    {
        return $this->model->find($id);
    }

    public function create(array $data): PortalService
    {
        return $this->model->create($data);
    }

    public function update(PortalService $service, array $data): PortalService
    {
        $service->update($data);
        return $service->fresh();
    }

    public function delete(PortalService $service): bool
    {
        return $service->delete();
    }
}
