<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('portal_services', function (Blueprint $table) {
            $table->id();
            $table->string('service_code');
            $table->string('service_name');
            $table->text('description')->nullable();
            $table->string('status');
            $table->string('link')->nullable();
            $table->integer('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('portal_services');
    }
};
