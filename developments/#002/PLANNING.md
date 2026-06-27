> ⚠️ **Note:** This is a reference document adapted from my-erp. File paths reference the original project structure. Adapt paths for RASHA microservices architecture (svc-core-laravel, svc-dynform-laravel, web-rasha-superapp-angular) when implementing.
# RASHA System — Development #002 Planning

## Phase 2: Advanced Modules & Navigation Restructure

**Last Updated:** 2025-05-18  
**Status:** ✅ Complete  
**Version:** 2.3.0

---

## 📋 Overview

Development #002 expands the ERP system from the initial 5 modules (Products, Warehouses, Inventory, Customers, Sales Orders) into a full-featured system covering Sales Operations, Procurement, Inventory Control, Financial Receivables, and Master Data management.

This phase also includes navigation restructuring for a business-flow-oriented user experience, and adds three new end-to-end modules: **Purchase Orders**, **Goods Received Notes**, and **Delivery/Shipping**.

---

## ✅ Completed in This Phase

### A. Completed Modules

| Module | FE | BE | DB | Status |
|--------|:--:|:--:|:--:|:------:|
| Sales Invoices | ✅ | ✅ | ✅ | Complete |
| Accounts Receivable (w/ Payments) | ✅ | ✅ | ✅ | Complete |
| Purchase Requests (w/ Workflow) | ✅ | ✅ | ✅ | Complete |
| Stock Opname (w/ Workflow) | ✅ | ✅ | ✅ | Complete |
| Sales Returns (w/ Workflow) | ✅ | ✅ | ✅ | Complete |
| Sales Persons | ✅ | ✅ | ✅ | Complete |
| Reports (Sales, Inventory, Customers) | ✅ | ✅ | — | Complete |
| Suppliers | ✅ | ✅ | ✅ | Complete |
| Bank Accounts | ✅ | ✅ | ✅ | Complete |
| Purchase Returns (w/ Workflow) | ✅ | ✅ | ✅ | Complete |

### B. Navigation Menu Restructure

| Change | Status |
|--------|:------:|
| **Master Data** — New group consolidating all 6 reference entities | ✅ |
| **Master Data Routes** — All entities under `/master-data/` | ✅ |
| **Sales** — Streamlined to core revenue cycle items | ✅ |
| **Sales Route Cleanup** — Removed persons & bank-accounts | ✅ |
| **Purchasing** — Streamlined to procurement cycle items | ✅ |
| **Purchasing Route Cleanup** — Removed suppliers | ✅ |
| **Inventory** — Transactions + Stock Opname grouped under parent | ✅ |
| **Navigation Component** — Business-flow ordering | ✅ |
| **Route References** — All component links updated | ✅ |
| **Old Standalone Routes Removed** — No more top-level `/products`, etc. | ✅ |

---

## 🔨 In Progress — New Modules

### C. Purchase Orders (PO)

**Status:** ✅ Complete  
**Priority:** 🔴 High  
**Dependencies:** Purchase Requests (complete), Suppliers (complete)

#### Business Context
The current Purchase Request workflow stops at `approved`. There is no formal Purchase Order (PO) document to send to the supplier. The PO bridges PR approval and goods receipt — it's the legal document sent to the supplier confirming the order.

#### Data Model

**`purchase_orders` table:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint (PK) | Auto-increment |
| `po_number` | string (unique) | Auto-generated: `PO-YYYYMMDD-XXXX` |
| `purchase_request_id` | FK → `purchase_requests` | Originating PR (nullable if PO created standalone) |
| `supplier_id` | FK → `suppliers` | Selected supplier |
| `status` | enum | `draft` → `sent` → `confirmed` → `partially_received` → `fully_received` → `closed` / `cancelled` |
| `order_date` | date | Date PO was issued |
| `expected_delivery_date` | date | Expected delivery from supplier |
| `subtotal` | decimal(15,2) | Sum of item totals |
| `tax_amount` | decimal(15,2) | Calculated tax |
| `discount_amount` | decimal(15,2) | Negotiated discount |
| `total_amount` | decimal(15,2) | Grand total |
| `currency_code` | string(3) | Default: IDR |
| `payment_terms` | string(100) | e.g. Net 30, Net 45 |
| `shipping_address` | text | Delivery address |
| `notes` | text | Internal notes |
| `created_by` | FK → `users` | PO creator |
| `approved_by` | FK → `users` | Authorized approver |
| `approved_at` | timestamp | Approval timestamp |
| `sent_at` | timestamp | When sent to supplier |
| `timestamps` | — | Laravel standard |

**`purchase_order_items` table:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint (PK) | Auto-increment |
| `purchase_order_id` | FK → `purchase_orders` | Parent PO |
| `purchase_request_item_id` | FK → `purchase_request_items` | Link back to PR item (nullable) |
| `product_id` | FK → `products` | Product being ordered |
| `description` | text | Item description |
| `quantity_ordered` | integer | Quantity ordered |
| `quantity_received` | integer | Quantity received so far (updated by GRN) |
| `unit_price` | decimal(15,2) | Price per unit |
| `total_price` | decimal(15,2) | Calculated = quantity_ordered × unit_price |
| `timestamps` | — | Laravel standard |

#### Workflow
```
draft → sent → confirmed → partially_received → fully_received → closed
  ↘        ↘
 cancelled  cancelled
```

#### Integration Points
| Action | Endpoint | Effect |
|--------|----------|--------|
| Generate PO from PR | `POST /purchase-requests/{id}/generate-po` | Creates PO pre-filled with PR items, supplier, notes |
| Send PO | `POST /purchase-orders/{id}/send` | Updates status → `sent`, records `sent_at` |
| Confirm PO | `POST /purchase-orders/{id}/confirm` | Supplier confirmed, status → `confirmed` |
| Cancel PO | `POST /purchase-orders/{id}/cancel` | Cancels PO (only if no GRN created) |
| Link PO to PR | Auto on creation | `purchase_request_id` set, PR status → `ordered` |

#### Reports Impact
- New report: PO status summary (open POs, expected deliveries)
- Update purchasing dashboard widget

#### Frontend
- **`PurchaseOrderListComponent`** — Table with PO number, supplier, status, expected delivery, amount
- **`PurchaseOrderFormComponent`** — Can create standalone or generate from PR; supplier/product dropdowns, items array, tax/discount fields
- **PO → GRN action button** — "Receive Goods" opens GRN form pre-filled with PO items

#### Route & Nav Updates
- Purchasing routes: add `{ path: 'orders', loadChildren: ... }` under `/purchasing/orders`
- Navigation: add "Purchase Orders" under Purchasing group (between Requests and Returns)

---

### D. Goods Received Note (GRN)

**Status:** ✅ Complete  
**Priority:** 🔴 High  
**Dependencies:** Purchase Orders (complete), Inventory Transactions (complete)

#### Business Context
When goods arrive from a supplier, a formal **Goods Received Note** records what was received, in what condition, and which warehouse it was stored in. The GRN also triggers an automatic inventory stock-in transaction.

#### Data Model

**`goods_received_notes` table:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint (PK) | Auto-increment |
| `grn_number` | string (unique) | Auto-generated: `GRN-YYYYMMDD-XXXX` |
| `purchase_order_id` | FK → `purchase_orders` | Source PO |
| `warehouse_id` | FK → `warehouses` | Receiving warehouse |
| `status` | enum | `draft` → `completed` → `cancelled` |
| `received_date` | date | Date of goods receipt |
| `delivery_note_number` | string(100) | Supplier's delivery note/DN number (optional) |
| `received_by` | FK → `users` | Person who received goods |
| `notes` | text | Receiving notes, remarks |
| `timestamps` | — | Laravel standard |

**`grn_items` table:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint (PK) | Auto-increment |
| `goods_received_note_id` | FK → `goods_received_notes` | Parent GRN |
| `purchase_order_item_id` | FK → `purchase_order_items` | Link to PO item |
| `product_id` | FK → `products` | Product received |
| `quantity_ordered` | integer | What was ordered (from PO item) |
| `quantity_received` | integer | What actually arrived |
| `quantity_accepted` | integer | Accepted qty (could be < received if damaged) |
| `quantity_rejected` | integer | Rejected qty (damaged, wrong item) |
| `rejection_reason` | text | Why rejected |
| `unit_price` | decimal(15,2) | Price per unit from PO |
| `timestamps` | — | Laravel standard |

#### Workflow
```
draft → completed → [auto-generates inventory IN transaction]
          ↘ cancelled
```

#### Integration Points
| Action | Endpoint | Effect |
|--------|----------|--------|
| Create GRN from PO | `POST /purchase-orders/{id}/receive` | Creates GRN pre-filled with PO items, auto-links to inventory |
| Complete GRN | `POST /goods-received-notes/{id}/complete` | Locks GRN, auto-creates Inventory Transaction (type: IN) for each accepted item, updates PO item `quantity_received` |
| Cancel GRN | `POST /goods-received-notes/{id}/cancel` | Reverses inventory transaction, only if no subsequent use |
| Auto-update PO | On GRN complete | Updates PO status to `partially_received` or `fully_received` based on item totals |
| Auto-update PR | Cascading from PO | PR status updates to match PO receipt status |

#### Inventory Transaction Generated
When GRN is completed, for each accepted item:
```json
{
  "product_id": "...",
  "warehouse_id": "...",
  "transaction_type": "IN",
  "quantity": <quantity_accepted>,
  "notes": "GRN #<grn_number> - PO #<po_number>",
  "created_by": <current_user>
}
```

#### Frontend
- **`GrnListComponent`** — Table with GRN number, PO number, supplier, warehouse, received date
- **`GrnFormComponent`** — Auto-loaded from PO with quantity fields for accepted/rejected, warehouse selection, rejection reason per item

#### Route & Nav Updates
- Purchasing routes: add `{ path: 'receiving', loadChildren: ... }` under `/purchasing/receiving`
- Navigation: add "Goods Receiving" under Purchasing group (between Orders and Returns)

---

### E. Delivery / Shipping

**Status:** ✅ Complete  
**Priority:** 🟡 Medium  
**Dependencies:** Sales Orders (complete)

#### Business Context
Currently, Sales Order statuses (`partially_delivered`, `fully_delivered`) are tracked as state transitions without a formal delivery document. A **Delivery** module creates formal delivery/shipping notes, tracks shipments, and links to inventory stock-out.

#### Data Model

**`deliveries` table:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint (PK) | Auto-increment |
| `delivery_number` | string (unique) | Auto-generated: `DEL-YYYYMMDD-XXXX` |
| `sales_order_id` | FK → `sales_orders` | Source SO |
| `customer_id` | FK → `customers` | Shipping to |
| `warehouse_id` | FK → `warehouses` | Warehouse goods ship from |
| `status` | enum | `draft` → `packed` → `shipped` → `delivered` → `cancelled` |
| `delivery_date` | date | Date of delivery |
| `shipping_method` | string(100) | Courier, internal, pickup |
| `tracking_number` | string(100) | Courier tracking number |
| `shipping_cost` | decimal(15,2) | Shipping cost |
| `shipping_address` | text | Delivery address (copy from SO or override) |
| `notes` | text | Shipping notes |
| `created_by` | FK → `users` | Delivery creator |
| `packed_by` | FK → `users` | Warehouse staff who packed |
| `packed_at` | timestamp | Packing completion time |
| `shipped_at` | timestamp | Actual ship-out time |
| `delivered_at` | timestamp | Confirmed delivery time |
| `timestamps` | — | Laravel standard |

**`delivery_items` table:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint (PK) | Auto-increment |
| `delivery_id` | FK → `deliveries` | Parent delivery |
| `sales_order_item_id` | FK → `sales_order_items` | Link to SO item (nullable) |
| `product_id` | FK → `products` | Product |
| `quantity_ordered` | integer | Original SO quantity |
| `quantity_delivered` | integer | Quantity in this delivery |
| `unit_price` | decimal(15,2) | Price from SO |
| `total_price` | decimal(15,2) | Calculated |
| `timestamps` | — | Laravel standard |

#### Workflow
```
draft → packed → shipped → delivered
           ↘ cancelled
```

#### Integration Points
| Action | Endpoint | Effect |
|--------|----------|--------|
| Create Delivery from SO | `POST /sales-orders/{id}/deliver` | Creates delivery pre-filled with SO items, sets SO status |
| Pack Delivery | `POST /deliveries/{id}/pack` | Updates status → `packed`, records `packed_by`, `packed_at` |
| Ship Delivery | `POST /deliveries/{id}/ship` | Updates status → `shipped`, `shipped_at`, auto-creates Inventory Transaction (type: OUT) |
| Confirm Delivery | `POST /deliveries/{id}/deliver` | Updates status → `delivered`, `delivered_at`, updates SO delivery status |
| Cancel Delivery | `POST /deliveries/{id}/cancel` | Reverses inventory if applicable |

#### Inventory Transaction Generated
On ship:
```json
{
  "product_id": "...",
  "warehouse_id": "...",
  "transaction_type": "OUT",
  "quantity": <quantity_delivered>,
  "notes": "Delivery #<delivery_number> - SO #<so_number>",
  "created_by": <current_user>
}
```

#### SO Status Link
When a delivery is confirmed:
- If sum of all delivered qty across all deliveries for the SO equals SO items' qty → SO status = `fully_delivered`
- Else SO status = `partially_delivered`
- If SO was `confirmed` → set to `partially_delivered`

#### Reports Impact
- New: Open deliveries report
- New: Delivery performance (on-time vs delayed)
- Add delivery data to existing sales reports

#### Frontend
- **`DeliveryListComponent`** — Table with delivery number, SO number, customer, status, shipping method, tracking
- **`DeliveryFormComponent`** — Create from SO with items, warehouse, shipping details

#### Route & Nav Updates
- Sales routes: add `{ path: 'deliveries', loadChildren: ... }` under `/sales/deliveries`
- Navigation: add "Deliveries" under Sales group (between Orders and Invoices)

---

## 📋 Updated Menu Structure (After Dev #002)

```
📊 Dashboard                /dashboard
📋 Master Data              (group)
├── Products                /master-data/products
├── Warehouses              /master-data/warehouses
├── Customers               /master-data/customers
├── Suppliers               /master-data/suppliers
├── Sales Persons           /master-data/sales-persons
├── Bank Accounts           /master-data/bank-accounts
📦 Inventory                (group)
├── Transactions            /inventory/transactions
├── Stock Opname            /inventory/opname
📈 Sales                    (group)
├── Sales Orders            /sales/orders
├── 📦 Deliveries           /sales/deliveries          ← NEW
├── Invoices                /sales/invoices
├── AR / Piutang            /sales/ar
├── Sales Returns           /sales/returns
📥 Purchasing               (group)
├── Purchase Requests       /purchasing/requests
├── 📄 Purchase Orders      /purchasing/orders         ← NEW
├── 📥 Goods Receiving      /purchasing/receiving       ← NEW
├── Purchase Returns        /purchasing/returns
📉 Reports                  /reports
```

### Business Flow Order (After Dev #002)

The expanded menu now covers the complete end-to-end business process:

1. **Dashboard** — Entry point, KPI overview
2. **Master Data** — Foundational reference entities
3. **Inventory** — Stock management
4. **Sales** — Revenue cycle (Orders → **Deliver** → Invoice → AR → Returns)
5. **Purchasing** — Procurement cycle (Request → **Order** → **Receive** → Return)
6. **Reports** — Analytics & insights

---

## 📊 Updated Business Flows

### 🔵 Procurement Cycle (After Dev #002)

```
Internal Need → Purchase Request → Approval → Purchase Order → Send to Supplier
    → Goods Received → Inventory Stock-In → Payment
```

| Step | Module | Status | Description |
|------|--------|--------|-------------|
| 1 | **Purchase Request** | ✅ | Department procurement, internal approval |
| 2 | **Purchase Order** | ✅ | Formal supplier-facing order document |
| 3 | **Goods Received Note** | ✅ | Formal receiving with inspection |
| 4 | **Inventory Stock-In** | ✅ | Auto-generated from GRN |
| 5 | **Purchase Returns** | ✅ | Supplier returns workflow |

### 🟢 Revenue Cycle (After Dev #002)

```
Customer → Sales Order → Confirm → Pack → Ship → Deliver → Invoice → AR → Payment
```

| Step | Module | Status | Description |
|------|--------|--------|-------------|
| 1 | **Sales Order** | ✅ | Order entry, confirmation |
| 2 | **Delivery** | ✅ | Pack → Ship → Deliver workflow with inventory OUT |
| 3 | **Sales Invoice** | ✅ | Billing |
| 4 | **Accounts Receivable** | ✅ | Payment collection |
| 5 | **Sales Returns** | ✅ | RMA workflow |

---

## ✅ Dev #002 Gap Fixes Applied

After the initial implementation, a post-completion audit identified 4 gaps. All have been fixed.

| # | Gap | Module | Fix | Severity |
|---|-----|--------|-----|:--------:|
| 1 | **Missing "pack" workflow step** | Deliveries | Added `pack()` controller method, `packed_by`/`packed_at` timestamp fields, `packed` status to enum. `ship()` now transitions from `packed` (not `packing`). Cancel accepts `packing` + `packed`. | 🟡 Medium |
| 2 | **Missing `warehouse_id` on GRN** | Goods Received Notes | Added `warehouse_id` FK migration. Controller validates warehouse on create; uses `grn.warehouse_id` in `complete()` (no more `Warehouse::first()` fallback). | 🟡 Medium |
| 3 | **Missing `warehouse_id` on Deliveries** | Deliveries | Added `warehouse_id` FK + `warehouse()` relation. Controller uses `delivery.warehouse_id` in `ship()`. | 🟡 Medium |
| 4 | **Missing `customer_id` on Deliveries** | Deliveries | Added `customer_id` FK + `customer()` relation. Controller auto-sets from SO's customer on `store()`. | 🟢 Low |

**Validation:** Zero TypeScript errors. All backend migrations, models, controllers updated. FE forms updated with warehouse selection.

---

## 🔲 Remaining Work After Dev #002

| Item | Type | Priority | Notes |
|------|------|:--------:|-------|
| **Chart of Accounts** | Module | 🟡 Medium | Foundation for formal accounting/GL integration |
| **General Ledger** | Module | 🟡 Medium | Double-entry bookkeeping |
| **Cash / Bank Management** | Module | 🟡 Medium | Bank reconciliation, cash flow tracking |
| **HR / Payroll** | Module | 🟡 Medium | Employee management, payroll processing |
| **Role-Based Access Control** | Enhancement | 🟡 Medium | Admin/manager/user roles, per-module permissions |

---

## Architecture Decisions

### Navigation Pattern
All grouped menus follow the same pattern:
```
Group (expandable/collapsible)
├── Child Item 1    /group/child1
├── Child Item 2    /group/child2
└── Child Item 3    /group/child3
```

### Route Nesting Pattern
```
app.routes.ts:
  /master-data  →  master-data.routes.ts
  /inventory    →  inventory.routes.ts
  /sales        →  sales.routes.ts:
                    /orders       →  sales-orders.routes.ts
                    /deliveries   →  deliveries.routes.ts         ← NEW
                    /invoices     →  (inline components)
                    /ar           →  accounts-receivable.routes.ts
                    /returns      →  sales-return.routes.ts
  /purchasing   →  purchasing.routes.ts:
                    /requests     →  purchase-request.routes.ts
                    /orders       →  purchase-order.routes.ts     ← NEW
                    /receiving    →  grn.routes.ts                ← NEW
                    /returns      →  purchase-return.routes.ts
  /reports      →  reports.routes.ts
```

### Status Workflow Pattern (Consistent)
All transactional modules follow the same pattern:
- Status changes via dedicated API endpoints (e.g., `POST /send`, `POST /confirm`)
- Read-only enum statuses enforced at DB level
- Status badges with distinct colors on frontend
- State machine validation: each status only accepts specific transitions

### Integration Pattern
- **PR → PO**: `purchase_request_id` FK on PO; PR status updates to `ordered` after PO generation
- **PO → GRN**: `purchase_order_id` FK on GRN; PO items track `quantity_received`
- **GRN → Inventory**: Auto-generates `inventory_transactions` with type `IN` on GRN complete
- **SO → Delivery**: `sales_order_id` FK on Delivery; SO status updates based on aggregated delivery quantity
- **Delivery → Inventory**: Auto-generates `inventory_transactions` with type `OUT` on ship

---

*Document Version: 2.3.0 | Last Updated: 2025-05-18*
