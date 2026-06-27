<?php

namespace App\Repositories;

use App\Models\PlatformConfig;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class PlatformConfigRepository
{
    public function __construct(
        protected PlatformConfig $model,
    ) {}

    public function paginate(int $perPage = 50): LengthAwarePaginator
    {
        return $this->model->orderBy('key')->paginate($perPage);
    }

    public function findByKey(string $key): ?PlatformConfig
    {
        return $this->model->where('key', $key)->first();
    }

    public function create(array $data): PlatformConfig
    {
        return $this->model->create($data);
    }

    public function update(PlatformConfig $config, array $data): PlatformConfig
    {
        $config->update($data);
        return $config->fresh();
    }

    public function delete(PlatformConfig $config): bool
    {
        return $config->delete();
    }
}
