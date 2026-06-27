<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('avatar')->nullable()->after('email');
            $table->string('phone', 20)->nullable()->after('avatar');
            $table->string('timezone', 50)->nullable()->default('Asia/Jakarta')->after('phone');
            $table->boolean('is_active')->default(true)->after('timezone');
            $table->timestamp('last_login_at')->nullable()->after('is_active');
            $table->string('last_login_ip', 45)->nullable()->after('last_login_at');
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'avatar',
                'phone',
                'timezone',
                'is_active',
                'last_login_at',
                'last_login_ip',
            ]);
            $table->dropSoftDeletes();
        });
    }
};
