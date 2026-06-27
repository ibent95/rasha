> ⚠️ **Note:** This is a reference document adapted from my-erp. File paths reference the original project structure. Adapt paths for RASHA microservices architecture (svc-core-laravel, svc-dynform-laravel, web-rasha-superapp-angular) when implementing.
# RASHA System — Development #003 Planning

## Phase 3: Core Accounting & Cash Management

**Last Updated:** 2025-05-18  
**Status:** 🚧 In Progress  
**Version:** 3.0.0

---

## 📋 Overview

Development #003 introduces the foundational accounting layer to RASHA. Currently, financial data exists across Sales Invoices, Accounts Receivable, Payments, and Bank Accounts — but without a formal chart of accounts or double-entry bookkeeping. This phase adds:

1. **Chart of Accounts (COA)** — The master list of all account categories used in the ledger
2. **General Ledger (GL)** — Double-entry journal entries with debit/credit posting
3. **Cash / Bank Management** — Bank deposits, withdrawals, transfers, and reconciliation

These modules lay the groundwork for future financial reports (balance sheet, income statement, cash flow statement) and auto-posting from operational transactions.

---

## 📊 Module Details

### A. Chart of Accounts (COA)

**Status:** 🚧 In Progress  
**Priority:** 🔴 High  
**Dependencies:** None (foundational module)

#### Business Context
A Chart of Accounts is the backbone of any accounting system. Every financial transaction ultimately posts to a COA account. The COA is organized hierarchically by account type and provides the structure for financial statements.

#### Data Model

**`chart_of_accounts` table:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint (PK) | Auto-increment |
| `account_code` | string(20) unique | Numeric code e.g. `1-1000`, `4-1000` |
| `name` | string(255) | Account name |
| `normal_balance` | enum(`debit`,`credit`) | Whether account increases with debit or credit |
| `category` | enum | `asset`,`liability`,`equity`,`income`,`expense` |
| `subcategory` | string(100) nullable | Grouping e.g. `current_asset`, `current_liability`, `cost_of_goods_sold` |
| `parent_id` | FK → `chart_of_accounts` nullable | Parent account for hierarchy |
| `is_active` | boolean | Can be used in transactions |
| `is_system` | boolean | System-protected account (cannot be deleted) |
| `description` | text nullable | Purpose of this account |
| `timestamps` | — | Laravel standard |

#### Standard Account Structure (Indonesian PSAK)

| Code Range | Category | Normal Balance | Examples |
|-----------|----------|---------------|---------|
| 1-xxxx | Asset | Debit | Cash, Bank, AR, Inventory, Fixed Assets |
| 2-xxxx | Liability | Credit | AP, VAT Payable, Accrued Expenses |
| 3-xxxx | Equity | Credit | Capital, Retained Earnings, Drawings |
| 4-xxxx | Income | Credit | Sales Revenue, Service Income, Discounts |
| 5-xxxx | Expense | Debit | COGS, Salaries, Rent, Utilities |

#### Auto-provisioning
On first run (seeder), create system accounts:
- `1-1000` Cash — `asset` / debit
- `1-1100` Bank — `asset` / debit
- `1-1200` Accounts Receivable — `asset` / debit
- `1-1300` Inventory — `asset` / debit
- `2-1000` Accounts Payable — `liability` / credit
- `2-1100` VAT Payable — `liability` / credit
- `3-1000` Retained Earnings — `equity` / credit
- `4-1000` Sales Revenue — `income` / credit
- `5-1000` Cost of Goods Sold — `expense` / debit

#### Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/chart-of-accounts` | List with search, category filter, hierarchy |
| POST | `/chart-of-accounts` | Create account |
| GET | `/chart-of-accounts/{id}` | Detail with children |
| PUT | `/chart-of-accounts/{id}` | Update account |
| DELETE | `/chart-of-accounts/{id}` | Delete (only if no transactions) |
| GET | `/chart-of-accounts/tree` | Return full hierarchical tree |

---

### B. General Ledger (Journal Entries)

**Status:** 🚧 In Progress  
**Priority:** 🔴 High  
**Dependencies:** Chart of Accounts (complete)

#### Business Context
The General Ledger records all financial transactions as journal entries with double-entry bookkeeping (at least two lines per entry: one debit, one credit). This is the core of accounting — every operational event that has a financial impact must be recorded here.

#### Data Model

**`journal_entries` table:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint (PK) | Auto-increment |
| `entry_number` | string(50) unique | Auto-generated: `GL-YYYYMMDD-XXXX` |
| `entry_date` | date | Date of transaction |
| `description` | text | Description of transaction |
| `status` | enum | `draft` → `posted` → `voided` |
| `reference_type` | string(50) nullable | Source document type e.g. `sales_invoice`, `payment`, `ar_payment` |
| `reference_id` | bigint nullable | Source document ID |
| `created_by` | FK → `users` | Entry creator |
| `posted_by` | FK → `users` nullable | Who posted the entry |
| `posted_at` | timestamp nullable | When posted |
| `voided_by` | FK → `users` nullable | Who voided |
| `voided_at` | timestamp nullable | When voided |
| `void_reason` | text nullable | Why voided |
| `timestamps` | — | Laravel standard |

**`journal_entry_items` table:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint (PK) | Auto-increment |
| `journal_entry_id` | FK → `journal_entries` | Parent entry |
| `chart_of_account_id` | FK → `chart_of_accounts` | Account posted to |
| `debit_amount` | decimal(15,2) | Debit amount (>= 0) |
| `credit_amount` | decimal(15,2) | Credit amount (>= 0) |
| `memo` | text nullable | Line item description |
| `timestamps` | — | Laravel standard |

#### Accounting Rules
- Every journal entry must have at least 2 items
- Total debits MUST equal total credits
- At least one line must have debit > 0, at least one line must have credit > 0
- Each line must have exactly one of debit OR credit > 0 (not both, not zero)
- Once posted, entries cannot be edited — only voided

#### Workflow
```
draft → posted → [can be] → voided
```

#### Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/journal-entries` | List with search, date range, status filter |
| POST | `/journal-entries` | Create draft entry with items |
| GET | `/journal-entries/{id}` | Detail with items |
| PUT | `/journal-entries/{id}` | Update draft entry only |
| POST | `/journal-entries/{id}/post` | Post entry (locks it, validates double-entry) |
| POST | `/journal-entries/{id}/void` | Void a posted entry |
| DELETE | `/journal-entries/{id}` | Delete draft only |

---

### C. Cash / Bank Management

**Status:** 🚧 In Progress  
**Priority:** 🟡 Medium  
**Dependencies:** Chart of Accounts (complete), Bank Accounts (complete)

#### Business Context
Cash and bank transactions are the most common financial events after invoices and payments. This module provides a dedicated interface for recording bank deposits, withdrawals, transfers between accounts, and bank reconciliation.

#### Data Model

**`bank_transactions` table:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint (PK) | Auto-increment |
| `bank_account_id` | FK → `bank_accounts` | Source bank account |
| `transaction_date` | date | Date of transaction |
| `transaction_type` | enum | `deposit`, `withdrawal`, `transfer_out`, `transfer_in`, `fee`, `interest` |
| `amount` | decimal(15,2) | Transaction amount (always positive) |
| `description` | text nullable | Transaction notes |
| `reference_number` | string(100) nullable | Check number, transfer ref, etc. |
| `reference_type` | string(50) nullable | e.g. `payment`, `ar_payment`, `transfer` |
| `reference_id` | bigint nullable | Link back to source document |
| `transfer_to_bank_account_id` | FK → `bank_accounts` nullable | Destination for transfers |
| `reconciled_at` | timestamp nullable | Bank reconciliation date |
| `reconciled_by` | FK → `users` nullable | Who reconciled |
| `chart_of_account_id` | FK → `chart_of_accounts` | COA account for GL posting |
| `created_by` | FK → `users` | Transaction creator |
| `timestamps` | — | Laravel standard |

#### Bank Reconciliation

The `bank_accounts` table gets two new fields:
| Field | Type | Description |
|-------|------|-------------|
| `opening_balance` | decimal(15,2) default 0 | Opening balance |
| `as_of_date` | date nullable | Date of opening balance |

#### Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/bank-transactions` | List with search, account filter, date range |
| POST | `/bank-transactions` | Create transaction (deposit/withdrawal/transfer) |
| GET | `/bank-transactions/{id}` | Detail |
| PUT | `/bank-transactions/{id}` | Update unreconciled |
| DELETE | `/bank-transactions/{id}` | Delete unreconciled only |
| POST | `/bank-transactions/{id}/reconcile` | Mark as reconciled |
| GET | `/bank-accounts/{id}/transactions` | List transactions for a specific account |
| GET | `/bank-accounts/{id}/balance` | Get current balance (sum of opening + transactions) |

---

## 🔗 Integration with Existing Modules

### Auto-Posting (Future)

In future developments, operational events will automatically post to GL:

| Event | Debit Account | Credit Account |
|-------|---------------|----------------|
| Sales Invoice Issued | AR (1-1200) | Sales Revenue (4-1000) |
| AR Payment Received | Bank (1-1100) | AR (1-1200) |
| GRN Completed (IN) | Inventory (1-1300) | AP (2-1000) |
| COGS Recognition | COGS (5-1000) | Inventory (1-1300) |
| Delivery Shipped (OUT) | COGS (5-1000) | Inventory (1-1300) |

For now, journal entries are created manually in the GL module. Auto-posting will use an event-based system in a future phase.

---

## 📋 Menu Structure (After Dev #003)

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
├── 📦 Deliveries           /sales/deliveries
├── Invoices                /sales/invoices
├── AR / Piutang            /sales/ar
├── Sales Returns           /sales/returns
📥 Purchasing               (group)
├── Purchase Requests       /purchasing/requests
├── 📄 Purchase Orders      /purchasing/orders
├── 📥 Goods Receiving      /purchasing/receiving
├── Purchase Returns        /purchasing/returns
📊 Accounting               (group)                  ← NEW
├── 📒 Chart of Accounts    /accounting/coa           ← NEW
├── 📓 Journal Entries      /accounting/journal        ← NEW
├── 💰 Bank Transactions    /accounting/bank           ← NEW
📉 Reports                  /reports
```

---

## 📊 Business Flow After Dev #003

### Revenue Cycle (with Accounting)
```
Customer → Sales Order → Deliver → Invoice → AR → Payment → [GL Entry posted]
```

### Procurement Cycle (with Accounting)
```
Request → Purchase Order → Receive Goods → [GL Entry posted] → Payment
```

### Accounting Cycle (Manual)
```
Chart of Accounts (setup) → Manual Journal Entry → Post → Review → Report
```

---

*Document Version: 3.0.0 | Last Updated: 2025-05-18*
