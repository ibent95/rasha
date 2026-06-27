<?php

namespace App\Repositories;

use App\Models\PortalApp;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;

class PortalAppRepository
{
    public function __construct(
        protected PortalApp $model,
    ) {}

    public function query(): Builder
    {
        return $this->model->query();
    }

    public function search(?string $search, ?bool $isActive, int $perPage = 15): LengthAwarePaginator
    {
        $query = $this->model->query();

        if ($search) {
            $query->where('app_name', 'like', "%{$search}%");
        }

        if ($isActive !== null) {
            $query->where('is_active', $isActive);
        }

        return $query->orderBy('sort_order')->paginate($perPage);
    }

    public function find(int $id): ?PortalApp
    {
        return $this->model->find($id);
    }

    public function create(array $data): PortalApp
    {
        return $this->model->create($data);
    }

    public function update(PortalApp $app, array $data): PortalApp
    {
        $app->update($data);
        return $app->fresh();
    }

    public function delete(PortalApp $app): bool
    {
        return $app->delete();
    }
}
