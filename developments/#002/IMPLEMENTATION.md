> ⚠️ **Note:** This is a reference document adapted from my-erp. File paths reference the original project structure. Adapt paths for RASHA microservices architecture (svc-core-laravel, svc-dynform-laravel, web-rasha-superapp-angular) when implementing.
# RASHA System — Development #002 Implementation

## Phase 2: Advanced Modules & Navigation Restructure

**Version:** 2.3.0
**Status:** ✅ Complete

---

## 📋 Implementation Overview

|          Module           | Status  | Started | Completed |
|---------------------------|---------|---------|-----------|
| Sales Invoices            | ✅ Done | Week 4  |  Week 5   |
| Accounts Receivable       | ✅ Done | Week 5  |  Week 6   |
| Purchase Requests         | ✅ Done | Week 4  |  Week 6   |
| Stock Opname              | ✅ Done | Week 5  |  Week 6   |
| Sales Returns             | ✅ Done | Week 6  |  Week 7   |
| Sales Persons             | ✅ Done | Week 7  |  Week 7   |
| Reports                   | ✅ Done | Week 7  |  Week 7   |
| Suppliers                 | ✅ Done | Week 8  |  Week 8   |
| Bank Accounts             | ✅ Done | Week 8  |  Week 8   |
| Purchase Returns          | ✅ Done | Week 8  |  Week 8   |
| Navigation Restructure    | ✅ Done | Week 8  |  Week 8   |
| **Purchase Orders**       | ✅ Done | Week 9  |  Week 9   |
| **Goods Received Notes**  | ✅ Done | Week 9  |  Week 9   |
| **Deliveries / Shipping** | ✅ Done | Week 9  |  Week 9   |

---

## Completed Module Details

### 1. Sales Invoices

**Backend:** ✅ Full CRUD with pagination, search, tax/discount fields
**Frontend:** ✅ List + Form with multi-item FormArray, auto-calculations

### 2. Accounts Receivable (Piutang)

**Backend:** ✅ Aging, payment, write-off, dispute, generate from invoice
**Frontend:** ✅ List with aging badges + Payment/Write-off forms

### 3. Purchase Requests

**Backend:** ✅ Full CRUD + submit/approve/cancel workflow, supplier selection
**Frontend:** ✅ List with status filters + Form with multi-item FormArray

### 4. Stock Opname

**Backend:** ✅ Start counting, update counts, complete, approve adjustment
**Frontend:** ✅ List + Form with variance calculation

### 5. Sales Returns

**Backend:** ✅ RMA workflow: approve → receive → inspect → credit note → close
**Frontend:** ✅ List + Form with disposition selection

### 6. Sales Persons

**Backend:** ✅ Full CRUD
**Frontend:** ✅ List + Form; moved under Master Data group

### 7. Reports

**Backend:** ✅ 9 report endpoints (Sales, Inventory, Customers)
**Frontend:** ✅ Tabbed report view

### 8. Suppliers

**Backend:** ✅ Full CRUD with search, filter, sort, pagination
**Frontend:** ✅ List + Form; moved under Master Data group

### 9. Bank Accounts

**Backend:** ✅ Full CRUD with currency/status filter
**Frontend:** ✅ List + Form; moved under Master Data group

### 10. Purchase Returns

**Backend:** ✅ Workflow: approve → send goods → debit note → close
**Frontend:** ✅ List with workflow actions + Form with items array

---

## 🔨 In Progress — New Modules

### 11. Purchase Orders (PO)

**Status:** ✅ Complete
**Priority:** 🔴 High
**Dependencies:** Purchase Requests (complete ✅), Suppliers (complete ✅)

#### Purpose

Bridge the gap between Purchase Request approval and goods receipt.
The PO is the formal document sent to the supplier confirming quantities,
prices, delivery date, and terms.

#### BE Implementation Plan

**Migration: `create_purchase_orders_table`**

```php
Schema::create('purchase_orders', function (Blueprint $table) {
    $table->id();
    $table->string('po_number')->unique();
    $table->foreignId('purchase_request_id')->nullable()->constrained()->nullOnDelete();
    $table->foreignId('supplier_id')->constrained();
    $table->string('status')->default('draft');
    $table->date('order_date');
    $table->date('expected_delivery_date')->nullable();
    $table->decimal('subtotal', 15, 2)->default(0);
    $table->decimal('tax_amount', 15, 2)->default(0);
    $table->decimal('discount_amount', 15, 2)->default(0);
    $table->decimal('total_amount', 15, 2)->default(0);
    $table->string('currency_code', 3)->default('IDR');
    $table->string('payment_terms', 100)->nullable();
    $table->text('shipping_address')->nullable();
    $table->text('notes')->nullable();
    $table->foreignId('created_by')->constrained('users');
    $table->foreignId('approved_by')->nullable()->constrained('users');
    $table->timestamp('approved_at')->nullable();
    $table->timestamp('sent_at')->nullable();
    $table->timestamps();
});
```

**Migration: `create_purchase_order_items_table`**

```php
Schema::create('purchase_order_items', function (Blueprint $table) {
    $table->id();
    $table->foreignId('purchase_order_id')->constrained()->cascadeOnDelete();
    $table->foreignId('purchase_request_item_id')->nullable()->constrained()->nullOnDelete();
    $table->foreignId('product_id')->constrained();
    $table->text('description');
    $table->integer('quantity_ordered');
    $table->integer('quantity_received')->default(0);
    $table->decimal('unit_price', 15, 2);
    $table->decimal('total_price', 15, 2);
    $table->timestamps();
});
```

**Controller: `PurchaseOrdersController`**

|  Method   |               Endpoint               |         Purpose          |
|-----------|--------------------------------------|--------------------------|
| `index`   | `GET /purchase-orders`               | List with search,        |
|           |                                      | status filter, sort,     |
|           |                                      | pagination.              |
| `store`   | `POST /purchase-orders`              | Create standalone PO     |
| `show`    | `GET /purchase-orders/{id}`          | Detail with items        |
| `update`  | `PUT /purchase-orders/{id}`          | Update draft PO only     |
| `send`    | `POST /purchase-orders/{id}/send`    | Mark as sent to supplier |
| `confirm` | `POST /purchase-orders/{id}/confirm` | Supplier confirmed       |
| `cancel`  | `POST /purchase-orders/{id}/cancel`  | Cancel draft/sent PO     |
| `destroy` | `DELETE /purchase-orders/{id}`       | Delete draft only        |

**Controller: `PurchaseRequestsController` — Additional Method**

|    Method    |                  Endpoint                  |     Purpose      |
|--------------|--------------------------------------------|------------------|
| `generatePo` | `POST /purchase-requests/{id}/generate-po` | Create PO from   |
|              |                                            | approved PR,     |
|              |                                            | sets PR status   |
|              |                                            | to `ordered`     |

**Route additions:**

```php
// Purchase Orders
Route::prefix('purchase-orders')->group(function () {
    Route::get('/', [PurchaseOrdersController::class, 'index']);
    Route::post('/', [PurchaseOrdersController::class, 'store']);
    Route::get('{id}', [PurchaseOrdersController::class, 'show']);
    Route::put('{id}', [PurchaseOrdersController::class, 'update']);
    Route::post('{id}/send', [PurchaseOrdersController::class, 'send']);
    Route::post('{id}/confirm', [PurchaseOrdersController::class, 'confirm']);
    Route::post('{id}/receive', [PurchaseOrdersController::class, 'createGrn']);  // Creates GRN from PO
    Route::post('{id}/cancel', [PurchaseOrdersController::class, 'cancel']);
    Route::delete('{id}', [PurchaseOrdersController::class, 'destroy']);
});

// Generate PO from PR (added to purchase-requests prefix)
Route::post('{id}/generate-po', [PurchaseRequestsController::class, 'generatePo']);
```

#### FE Implementation Plan

| Component | Route | Description |
|-----------|-------|-------------|
| `PurchaseOrderListComponent` | `/purchasing/orders` | Table with PO#, supplier, status, expected delivery, amount |
| `PurchaseOrderFormComponent` | `/purchasing/orders/create`, `/edit/:id` | Supplier select, items with product search, tax/discount, shipping address |

**Service: `PurchaseOrderService`**

| Method | API Call |
|--------|----------|
| `getList(params)` | `GET /purchase-orders` |
| `getDetail(id)` | `GET /purchase-orders/{id}` |
| `create(data)` | `POST /purchase-orders` |
| `update(id, data)` | `PUT /purchase-orders/{id}` |
| `send(id)` | `POST /purchase-orders/{id}/send` |
| `confirm(id)` | `POST /purchase-orders/{id}/confirm` |
| `cancel(id)` | `POST /purchase-orders/{id}/cancel` |
| `delete(id)` | `DELETE /purchase-orders/{id}` |

#### Files to Create

- `services/svc-rasha-laravel/database/migrations/2025_03_15_000001_create_purchase_orders_table.php`
- `services/svc-rasha-laravel/app/Models/PurchaseOrder.php`
- `services/svc-rasha-laravel/app/Models/PurchaseOrderItem.php`
- `services/svc-rasha-laravel/app/Http/Controllers/API/PurchaseOrdersController.php`
- `websites/web-rasha-angular/src/app/modules/purchase-orders/purchase-order.routes.ts`
- `websites/web-rasha-angular/src/app/modules/purchase-orders/purchase-order-list.component.ts`
- `websites/web-rasha-angular/src/app/modules/purchase-orders/purchase-order-form.component.ts`
- `websites/web-rasha-angular/src/app/shared/services/purchase-order.service.ts`
- `websites/web-rasha-angular/src/app/shared/models/index.ts` (update `PurchaseOrder` interface)

---

### 12. Goods Received Notes (GRN)

**Status:** ✅ Complete
**Priority:** 🔴 High
**Dependencies:** Purchase Orders (✅), Inventory Transactions (✅)

#### Purpose

Formalize goods receiving from suppliers with inspection, rejection tracking,
and automatic inventory stock-in.

#### BE Implementation Plan

**Migration: `create_goods_received_notes_table`**

```php
Schema::create('goods_received_notes', function (Blueprint $table) {
    $table->id();
    $table->string('grn_number')->unique();
    $table->foreignId('purchase_order_id')->constrained();
    $table->foreignId('warehouse_id')->constrained();
    $table->string('status')->default('draft');
    $table->date('received_date');
    $table->string('delivery_note_number', 100)->nullable();
    $table->foreignId('received_by')->constrained('users');
    $table->text('notes')->nullable();
    $table->timestamps();
});
```

**Migration: `create_grn_items_table`**

```php
Schema::create('grn_items', function (Blueprint $table) {
    $table->id();
    $table->foreignId('goods_received_note_id')->constrained()->cascadeOnDelete();
    $table->foreignId('purchase_order_item_id')->constrained();
    $table->foreignId('product_id')->constrained();
    $table->integer('quantity_ordered');
    $table->integer('quantity_received');
    $table->integer('quantity_accepted');
    $table->integer('quantity_rejected')->default(0);
    $table->text('rejection_reason')->nullable();
    $table->decimal('unit_price', 15, 2);
    $table->timestamps();
});
```

**Controller: `GoodsReceivedNotesController`**

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `index` | `GET /goods-received-notes` | List with search, PO filter, warehouse filter |
| `store` | `POST /goods-received-notes` | Create from PO |
| `show` | `GET /goods-received-notes/{id}` | Detail with items |
| `complete` | `POST /goods-received-notes/{id}/complete` | Lock GRN, create inventory IN transactions |
| `cancel` | `POST /goods-received-notes/{id}/cancel` | Cancel draft only |
| `destroy` | `DELETE /goods-received-notes/{id}` | Delete draft only |

**Inventory Integration (on `complete`):**

```php
foreach ($grn->items as $item) {
    if ($item->quantity_accepted > 0) {
        InventoryTransaction::create([
            'product_id' => $item->product_id,
            'warehouse_id' => $grn->warehouse_id,
            'transaction_type' => 'IN',
            'quantity' => $item->quantity_accepted,
            'notes' => "GRN #{$grn->grn_number} - PO #{$grn->purchaseOrder->po_number}",
            'created_by' => $grn->received_by,
        ]);

        // Update product stock
        Product::where('id', $item->product_id)
            ->increment('stock_quantity', $item->quantity_accepted);
    }

    // Update PO item received quantity
    $poItem = $item->purchaseOrderItem;
    $poItem->increment('quantity_received', $item->quantity_accepted);
}

// Update PO status
$po = $grn->purchaseOrder;
$allFullyReceived = $po->items->every(fn($i) => $i->quantity_received >= $i->quantity_ordered);
$anyReceived = $po->items->sum('quantity_received') > 0;
$po->update(['status' => $allFullyReceived ? 'fully_received' : 'partially_received']);
```

#### FE Implementation Plan

| Component | Route | Description |
|-----------|-------|-------------|
| `GrnListComponent` | `/purchasing/receiving` | Table with GRN#, PO#, supplier, warehouse, received date |
| `GrnFormComponent` | `/purchasing/receiving/create` | Pre-filled from PO with accepted/rejected qty fields |

**Service: `GoodsReceivedNoteService`**

| Method | API Call |
|--------|----------|
| `getList(params)` | `GET /goods-received-notes` |
| `getDetail(id)` | `GET /goods-received-notes/{id}` |
| `create(data)` | `POST /goods-received-notes` |
| `complete(id)` | `POST /goods-received-notes/{id}/complete` |
| `cancel(id)` | `POST /goods-received-notes/{id}/cancel` |
| `delete(id)` | `DELETE /goods-received-notes/{id}` |

#### Files to Create

- `services/svc-rasha-laravel/database/migrations/2025_03_15_000002_create_goods_received_notes_table.php`
- `services/svc-rasha-laravel/database/migrations/2025_03_15_000003_create_grn_items_table.php`
- `services/svc-rasha-laravel/app/Models/GoodsReceivedNote.php`
- `services/svc-rasha-laravel/app/Models/GrnItem.php`
- `services/svc-rasha-laravel/app/Http/Controllers/API/GoodsReceivedNotesController.php`
- `websites/web-rasha-angular/src/app/modules/grn/grn.routes.ts`
- `websites/web-rasha-angular/src/app/modules/grn/grn-list.component.ts`
- `websites/web-rasha-angular/src/app/modules/grn/grn-form.component.ts`
- `websites/web-rasha-angular/src/app/shared/services/grn.service.ts`
- `websites/web-rasha-angular/src/app/shared/models/index.ts` (update with GRN interfaces)

---

### 13. Deliveries / Shipping

**Status:** ✅ Complete
**Priority:** 🟡 Medium
**Dependencies:** Sales Orders (✅)

#### Purpose

Formalize the shipment/delivery process for Sales Orders
with pack → ship → deliver workflow, tracking numbers, and automatic inventory stock-out.

#### BE Implementation Plan

**Migration: `create_deliveries_table`**

```php
Schema::create('deliveries', function (Blueprint $table) {
    $table->id();
    $table->string('delivery_number')->unique();
    $table->foreignId('sales_order_id')->constrained();
    $table->foreignId('customer_id')->constrained();
    $table->foreignId('warehouse_id')->constrained();
    $table->string('status')->default('draft');
    $table->date('delivery_date');
    $table->string('shipping_method', 100)->nullable();
    $table->string('tracking_number', 100)->nullable();
    $table->decimal('shipping_cost', 15, 2)->default(0);
    $table->text('shipping_address')->nullable();
    $table->text('notes')->nullable();
    $table->foreignId('created_by')->constrained('users');
    $table->foreignId('packed_by')->nullable()->constrained('users');
    $table->timestamp('packed_at')->nullable();
    $table->timestamp('shipped_at')->nullable();
    $table->timestamp('delivered_at')->nullable();
    $table->timestamps();
});
```

**Migration: `create_delivery_items_table`**

```php
Schema::create('delivery_items', function (Blueprint $table) {
    $table->id();
    $table->foreignId('delivery_id')->constrained()->cascadeOnDelete();
    $table->foreignId('sales_order_item_id')->nullable()->constrained()->nullOnDelete();
    $table->foreignId('product_id')->constrained();
    $table->integer('quantity_ordered');
    $table->integer('quantity_delivered');
    $table->decimal('unit_price', 15, 2);
    $table->decimal('total_price', 15, 2);
    $table->timestamps();
});
```

**Controller: `DeliveriesController`**

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `index` | `GET /deliveries` | List with search, status filter, date range |
| `store` | `POST /deliveries` | Create from SO |
| `show` | `GET /deliveries/{id}` | Detail with items |
| `update` | `PUT /deliveries/{id}` | Update draft |
| `pack` | `POST /deliveries/{id}/pack` | Mark as packed |
| `ship` | `POST /deliveries/{id}/ship` | Mark as shipped, create inventory OUT |
| `deliver` | `POST /deliveries/{id}/deliver` | Confirm delivery, update SO status |
| `cancel` | `POST /deliveries/{id}/cancel` | Cancel, reverse inventory if shipped |
| `destroy` | `DELETE /deliveries/{id}` | Delete draft only |

**Controller: `SalesOrdersController` — Additional Method**

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `createDelivery` | `POST /sales-orders/{id}/deliver` | Create delivery pre-filled with SO items, updates SO status |

#### FE Implementation Plan

| Component | Route | Description |
|-----------|-------|-------------|
| `DeliveryListComponent` | `/sales/deliveries` | Table with delivery#, SO#, customer, status, tracking, ship method |
| `DeliveryFormComponent` | `/sales/deliveries/create`, `/edit/:id` | SO select, items, warehouse, shipping details, tracking |

**Service: `DeliveryService`**

| Method | API Call |
|--------|----------|
| `getList(params)` | `GET /deliveries` |
| `getDetail(id)` | `GET /deliveries/{id}` |
| `create(data)` | `POST /deliveries` |
| `update(id, data)` | `PUT /deliveries/{id}` |
| `pack(id)` | `POST /deliveries/{id}/pack` |
| `ship(id)` | `POST /deliveries/{id}/ship` |
| `deliver(id)` | `POST /deliveries/{id}/deliver` |
| `cancel(id)` | `POST /deliveries/{id}/cancel` |
| `delete(id)` | `DELETE /deliveries/{id}` |

#### Files to Create

- `services/svc-rasha-laravel/database/migrations/2025_03_15_000004_create_deliveries_table.php`
- `services/svc-rasha-laravel/database/migrations/2025_03_15_000005_create_delivery_items_table.php`
- `services/svc-rasha-laravel/app/Models/Delivery.php`
- `services/svc-rasha-laravel/app/Models/DeliveryItem.php`
- `services/svc-rasha-laravel/app/Http/Controllers/API/DeliveriesController.php`
- `websites/web-rasha-angular/src/app/modules/deliveries/delivery.routes.ts`
- `websites/web-rasha-angular/src/app/modules/deliveries/delivery-list.component.ts`
- `websites/web-rasha-angular/src/app/modules/deliveries/delivery-form.component.ts`
- `websites/web-rasha-angular/src/app/shared/services/delivery.service.ts`
- `websites/web-rasha-angular/src/app/shared/models/index.ts` (update with Delivery interfaces)

---

## Navigation & Route Updates (Remaining)

### Files to Update

| File | Change |
|------|--------|
| `purchasing.routes.ts` | Add `orders` + `receiving` children |
| `sales.routes.ts` | Add `deliveries` child |
| `navigation.component.ts` | Add "Purchase Orders" + "Goods Receiving" under Purchasing; add "Deliveries" under Sales |

### Final Menu Structure After Dev #002

```
📊 Dashboard                /dashboard
📋 Master Data              (group)
  └ Products, Warehouses, Customers, Suppliers, Sales Persons, Bank Accounts
📦 Inventory                (group)
  └ Transactions, Stock Opname
📈 Sales                    (group)
  └ Sales Orders, Deliveries, Invoices, AR/Piutang, Sales Returns
📥 Purchasing               (group)
  └ Purchase Requests, Purchase Orders, Goods Receiving, Purchase Returns
📉 Reports                  /reports
```

---

## Data Model Summary — New Entities

| Entity | DB Table | FE Model |
|--------|----------|----------|
| Purchase Order | `purchase_orders` + `purchase_order_items` | `PurchaseOrder`, `PurchaseOrderItem` |
| Goods Received Note | `goods_received_notes` + `grn_items` | `GoodsReceivedNote`, `GrnItem` |
| Delivery / Shipping | `deliveries` + `delivery_items` | `Delivery`, `DeliveryItem` |

---

## Remaining Work After Dev #002

| Item | Status | Notes |
|------|--------|-------|
| **Purchase Orders — BE** | ✅ Complete | Migration, Model, Controller (8 workflow methods) |
| **Purchase Orders — FE** | ✅ Complete | List, Form, Service, Routes (with search, status filter, pagination, workflow actions) |
| **Goods Received Notes — BE** | ✅ Complete | Migration, Model, Controller (with inventory IN on complete, PO status cascade) |
| **Goods Received Notes — FE** | ✅ Complete | List, Form, Service, Routes (with qty accepted/rejected, warehouse) |
| **Deliveries — BE** | ✅ Complete | Migration, Model, Controller (pack→ship→deliver, inventory OUT, SO status cascade) |
| **Deliveries — FE** | ✅ Complete | List, Form, Service, Routes (with quick-create from SO) |
| **Nav & Route Updates** | ✅ Complete | purchasing/sales routes + navigation.component updated |

### Build Fixes Applied

| Issue | Fix |
|-------|-----|
| `loadPRs()` → `loadPOs()` in `purchase-order-list.component.ts` | 4 leftover references renamed after method rename from `loadPRs` to `loadPOs` |
| Missing `subtotal` in `delivery-form.component.ts` | Added `subtotal: qty * unit_price` to each delivery item payload |
| Missing `subtotal` in `goods-received-note-form.component.ts` | Added `subtotal: qty_accepted * unit_price` to each GRN item payload |

**TypeScript:** All three modules pass `tsc --noEmit` with zero errors.

### Dev #002 Gap Fixes

After the initial implementation, a post-completion audit identified 4 gaps in the Delivery and GRN modules. All have been fixed.

| # | Gap | Module | Files Changed | Fix Summary |
|---|-----|--------|---------------|-------------|
| 1 | **Missing "pack" workflow step** | Deliveries | `2026_01_01_000038_update_deliveries_table.php` (migration), `Delivery.php` (model), `DeliveriesController.php`, `routes/api.php`, `delivery.service.ts`, `delivery-list.component.ts` | Added `pack()` method transitioning `packing→packed`, records `packed_by`/`packed_at`. `ship()` now requires `packed` status. `cancel()` accepts both `packing` and `packed`. FE: Pack button, packed status filter/badge. |
| 2 | **Missing `warehouse_id` on GRN** | Goods Received Notes | `2026_01_01_000037_add_warehouse_id_to_goods_received_notes.php` (migration), `GoodsReceivedNote.php` (model), `GoodsReceivedNotesController.php`, `goods-received-note-form.component.ts` | Added `warehouse_id` FK (nullable) to `goods_received_notes`. Controller validates required on store; uses `grn.warehouse_id` in `complete()` instead of `Warehouse::first()`. FE: warehouse select field on GRN form. |
| 3 | **Missing `warehouse_id` on Deliveries** | Deliveries | `2026_01_01_000038_update_deliveries_table.php` (migration), `Delivery.php` (model), `DeliveriesController.php`, `delivery-form.component.ts` | Added `warehouse_id` FK to deliveries migration. Controller uses `delivery.warehouse_id` in `ship()`. FE: warehouse select field on delivery form. |
| 4 | **Missing `customer_id` on Deliveries** | Deliveries | `2026_01_01_000038_update_deliveries_table.php` (migration), `Delivery.php` (model), `DeliveriesController.php` | Added `customer_id` FK to deliveries migration. Controller auto-sets from SO's customer_id on `store()`. FE list shows customer name from `del.customer?.name` fallback. |

**TypeScript:** Zero errors after all gap fixes. |

---

## Validation Status

| Check | Status |
|-------|:------:|
| All Modules — Backend (Laravel migrations, models, controllers) | ✅ Complete |
| All Modules — Frontend (Angular components, services, routes) | ✅ Complete |
| All Modules — TypeScript (`tsc --noEmit`) | ✅ Zero errors |
| Navigation & Routes — All links verified | ✅ Complete |

---

*Document Version: 2.3.0 | Last Updated: 2025-05-18*
