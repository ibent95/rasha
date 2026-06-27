<?php

namespace App\Services;

use App\Models\PlatformConfig;
use App\Repositories\PlatformConfigRepository;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class PlatformConfigService
{
    public function __construct(
        protected PlatformConfigRepository $repository,
    ) {}

    public function paginate(int $perPage = 50): LengthAwarePaginator
    {
        return $this->repository->paginate($perPage);
    }

    public function findByKey(string $key): ?PlatformConfig
    {
        return $this->repository->findByKey($key);
    }

    public function create(array $data): PlatformConfig
    {
        return $this->repository->create($data);
    }

    public function update(PlatformConfig $config, array $data): PlatformConfig
    {
        return $this->repository->update($config, $data);
    }

    public function delete(PlatformConfig $config): bool
    {
        return $this->repository->delete($config);
    }
}
