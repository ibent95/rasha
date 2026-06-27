<?php

namespace App\Http\Controllers;

use App\Models\PortalCarouselSlide;
use App\Services\PortalCarouselSlideService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PortalCarouselSlideController extends Controller
{
    public function __construct(
        protected PortalCarouselSlideService $service,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $slides = $this->service->search(
            $request->has('is_active') ? $request->boolean('is_active') : null,
            $request->input('per_page', 15),
        );

        return response()->json([
            'success' => true,
            'data' => $slides,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'image_path' => 'required|string|max:500',
            'link' => 'nullable|string|max:500',
            'sort_order' => 'nullable|integer|min:0',
            'is_active' => 'nullable|boolean',
        ]);

        $slide = $this->service->create($validated);

        return response()->json([
            'success' => true,
            'data' => $slide,
            'message' => 'Carousel slide created successfully',
        ], 201);
    }

    public function show(PortalCarouselSlide $portalCarouselSlide): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => $portalCarouselSlide,
        ]);
    }

    public function update(Request $request, PortalCarouselSlide $portalCarouselSlide): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'image_path' => 'sometimes|required|string|max:500',
            'link' => 'nullable|string|max:500',
            'sort_order' => 'nullable|integer|min:0',
            'is_active' => 'nullable|boolean',
        ]);

        $slide = $this->service->update($portalCarouselSlide, $validated);

        return response()->json([
            'success' => true,
            'data' => $slide,
            'message' => 'Carousel slide updated successfully',
        ]);
    }

    public function destroy(PortalCarouselSlide $portalCarouselSlide): JsonResponse
    {
        $this->service->delete($portalCarouselSlide);

        return response()->json([
            'success' => true,
            'message' => 'Carousel slide deleted successfully',
        ]);
    }
}
