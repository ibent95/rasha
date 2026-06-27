<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Services\ProfileService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rules\Password;

class ProfileController extends Controller
{
    public function __construct(
        protected ProfileService $profileService,
    ) {}

    public function show(Request $request): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => $this->profileService->show($request->user()),
        ]);
    }

    public function update(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $request->user()->id,
            'phone' => 'sometimes|nullable|string|max:20',
            'timezone' => 'sometimes|nullable|string|max:50',
            'avatar' => 'sometimes|nullable|string|max:255',
        ]);

        $user = $this->profileService->update($request->user(), $validated);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => [
                'user' => $user,
            ],
        ]);
    }

    public function updatePassword(Request $request): JsonResponse
    {
        $request->validate([
            'current_password' => 'required',
            'password' => ['required', 'confirmed', Password::min(8)->mixedCase()->numbers()],
        ]);

        $this->profileService->updatePassword(
            $request->user(),
            $request->current_password,
            $request->password,
        );

        return response()->json([
            'success' => true,
            'message' => 'Password updated successfully',
        ]);
    }
}
