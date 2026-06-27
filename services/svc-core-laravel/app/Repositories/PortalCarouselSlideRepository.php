<?php

namespace App\Repositories;

use App\Models\PortalCarouselSlide;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class PortalCarouselSlideRepository
{
    public function __construct(
        protected PortalCarouselSlide $model,
    ) {}

    public function search(?bool $isActive, int $perPage = 15): LengthAwarePaginator
    {
        $query = $this->model->query();

        if ($isActive !== null) {
            $query->where('is_active', $isActive);
        }

        return $query->orderBy('sort_order')->paginate($perPage);
    }

    public function find(int $id): ?PortalCarouselSlide
    {
        return $this->model->find($id);
    }

    public function create(array $data): PortalCarouselSlide
    {
        return $this->model->create($data);
    }

    public function update(PortalCarouselSlide $slide, array $data): PortalCarouselSlide
    {
        $slide->update($data);
        return $slide->fresh();
    }

    public function delete(PortalCarouselSlide $slide): bool
    {
        return $slide->delete();
    }
}
