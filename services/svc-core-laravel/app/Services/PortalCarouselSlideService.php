<?php

namespace App\Services;

use App\Models\PortalCarouselSlide;
use App\Repositories\PortalCarouselSlideRepository;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class PortalCarouselSlideService
{
    public function __construct(
        protected PortalCarouselSlideRepository $repository,
    ) {}

    public function search(?bool $isActive, int $perPage = 15): LengthAwarePaginator
    {
        return $this->repository->search($isActive, $perPage);
    }

    public function find(int $id): ?PortalCarouselSlide
    {
        return $this->repository->find($id);
    }

    public function create(array $data): PortalCarouselSlide
    {
        return $this->repository->create($data);
    }

    public function update(PortalCarouselSlide $slide, array $data): PortalCarouselSlide
    {
        return $this->repository->update($slide, $data);
    }

    public function delete(PortalCarouselSlide $slide): bool
    {
        return $this->repository->delete($slide);
    }
}
