> ⚠️ **Note:** This is a reference document adapted from my-erp. File paths reference the original project structure. Adapt paths for RASHA microservices architecture (svc-core-laravel, svc-dynform-laravel, web-rasha-superapp-angular) when implementing.
# RASHA System — Development #003 Implementation

## Phase 3: Core Accounting & Cash Management

**Version:** 3.0.0  
**Status:** 🚧 In Progress

---

## 📋 Implementation Overview

| Module | Status | Files | 
|--------|--------|-------|
| **Chart of Accounts** | 🚧 In Progress | 2 migrations, 1 model, 1 controller, 3 FE files |
| **General Ledger** | 🚧 In Progress | 2 migrations, 2 models, 1 controller, 3 FE files |
| **Cash / Bank Management** | 🚧 In Progress | 1 migration, 1 model (+ BankAccount update), 1 controller, 3 FE files |
| **Navigation & Routes** | 🚧 In Progress | accounting.routes.ts, app.routes.ts, navigation.component.ts |

---

## Implementation Details

### 1. Chart of Accounts

#### Migration: `create_chart_of_accounts_table`
```php
Schema::create('chart_of_accounts', function (Blueprint $table) {
    $table->id();
    $table->string('account_code', 20)->unique();
    $table->string('name', 255);
    $table->enum('normal_balance', ['debit', 'credit']);
    $table->enum('category', ['asset', 'liability', 'equity', 'income', 'expense']);
    $table->string('subcategory', 100)->nullable();
    $table->foreignId('parent_id')->nullable()->constrained('chart_of_accounts')->nullOnDelete();
    $table->boolean('is_active')->default(true);
    $table->boolean('is_system')->default(false);
    $table->text('description')->nullable();
    $table->timestamps();
});
```

#### Model: `ChartOfAccount`
- $fillable: account_code, name, normal_balance, category, subcategory, parent_id, is_active, is_system, description
- $casts: is_active => boolean, is_system => boolean
- Relations: parent() (belongsTo self), children() (hasMany self)
- Scopes: active(), byCategory()

#### Controller: `ChartOfAccountsController`
| Method | Endpoint | Purpose |
|--------|----------|---------|
| index | GET /chart-of-accounts | List with search, category filter |
| store | POST /chart-of-accounts | Create account |
| show | GET /chart-of-accounts/{id} | Detail with children |
| update | PUT /chart-of-accounts/{id} | Update account |
| destroy | DELETE /chart-of-accounts/{id} | Delete (only if no journal entries) |
| tree | GET /chart-of-accounts/tree | Return hierarchical tree |

### 2. General Ledger

#### Migration: `create_journal_entries_table`
```php
Schema::create('journal_entries', function (Blueprint $table) {
    $table->id();
    $table->string('entry_number', 50)->unique();
    $table->date('entry_date');
    $table->text('description');
    $table->string('status')->default('draft');
    $table->string('reference_type', 50)->nullable();
    $table->bigInteger('reference_id')->nullable();
    $table->foreignId('created_by')->constrained('users');
    $table->foreignId('posted_by')->nullable()->constrained('users');
    $table->timestamp('posted_at')->nullable();
    $table->foreignId('voided_by')->nullable()->constrained('users');
    $table->timestamp('voided_at')->nullable();
    $table->text('void_reason')->nullable();
    $table->timestamps();
});
```

#### Migration: `create_journal_entry_items_table`
```php
Schema::create('journal_entry_items', function (Blueprint $table) {
    $table->id();
    $table->foreignId('journal_entry_id')->constrained()->cascadeOnDelete();
    $table->foreignId('chart_of_account_id')->constrained('chart_of_accounts');
    $table->decimal('debit_amount', 15, 2)->default(0);
    $table->decimal('credit_amount', 15, 2)->default(0);
    $table->text('memo')->nullable();
    $table->timestamps();
});
```

#### Models
**`JournalEntry`**
- $fillable: entry_number, entry_date, description, status, reference_type, reference_id, created_by, posted_by, posted_at, voided_by, voided_at, void_reason
- Relations: items(), creator(), postedBy(), voidedBy()
- Scopes: draft(), posted()

**`JournalEntryItem`**
- $fillable: journal_entry_id, chart_of_account_id, debit_amount, credit_amount, memo
- Relations: journalEntry(), account()

#### Controller: `JournalEntriesController`
| Method | Endpoint | Purpose |
|--------|----------|---------|
| index | GET /journal-entries | List with search, date range, status filter |
| store | POST /journal-entries | Create with items (validates debits=credits) |
| show | GET /journal-entries/{id} | Detail with items |
| update | PUT /journal-entries/{id} | Update draft only |
| post | POST /journal-entries/{id}/post | Post entry, lock it |
| void | POST /journal-entries/{id}/void | Void posted entry |
| destroy | DELETE /journal-entries/{id} | Delete draft only |

### 3. Cash / Bank Management

#### Migration: `create_bank_transactions_table`
```php
Schema::create('bank_transactions', function (Blueprint $table) {
    $table->id();
    $table->foreignId('bank_account_id')->constrained();
    $table->date('transaction_date');
    $table->enum('transaction_type', ['deposit', 'withdrawal', 'transfer_out', 'transfer_in', 'fee', 'interest']);
    $table->decimal('amount', 15, 2);
    $table->text('description')->nullable();
    $table->string('reference_number', 100)->nullable();
    $table->string('reference_type', 50)->nullable();
    $table->bigInteger('reference_id')->nullable();
    $table->foreignId('transfer_to_bank_account_id')->nullable()->constrained('bank_accounts');
    $table->timestamp('reconciled_at')->nullable();
    $table->foreignId('reconciled_by')->nullable()->constrained('users');
    $table->foreignId('chart_of_account_id')->nullable()->constrained('chart_of_accounts');
    $table->foreignId('created_by')->constrained('users');
    $table->timestamps();
});
```

#### Migration: `add_opening_balance_to_bank_accounts`
```php
Schema::table('bank_accounts', function (Blueprint $table) {
    $table->decimal('opening_balance', 15, 2)->default(0);
    $table->date('as_of_date')->nullable();
});
```

#### Model: `BankTransaction`
- $fillable: bank_account_id, transaction_date, transaction_type, amount, description, reference_number, reference_type, reference_id, transfer_to_bank_account_id, reconciled_at, reconciled_by, chart_of_account_id, created_by
- Relations: bankAccount(), transferToBankAccount(), reconciledBy(), creator(), coaAccount()
- For transfers: creates TWO transactions (transfer_out on source, transfer_in on destination)

#### Controller: `CashFlowController`
| Method | Endpoint | Purpose |
|--------|----------|---------|
| index | GET /bank-transactions | List with search, account filter, date range |
| store | POST /bank-transactions | Create deposit/withdrawal/transfer |
| show | GET /bank-transactions/{id} | Detail |
| update | PUT /bank-transactions/{id} | Update unreconciled |
| destroy | DELETE /bank-transactions/{id} | Delete unreconciled only |
| reconcile | POST /bank-transactions/{id}/reconcile | Mark reconciled |
| accountTransactions | GET /bank-accounts/{id}/transactions | Transactions for account |
| accountBalance | GET /bank-accounts/{id}/balance | Current balance |

---

## Files to Create / Modify

### Backend — New Files

| File | Module |
|------|--------|
| `database/migrations/2026_01_01_000039_create_chart_of_accounts_table.php` | COA |
| `database/migrations/2026_01_01_000040_create_journal_entries_table.php` | GL |
| `database/migrations/2026_01_01_000041_create_journal_entry_items_table.php` | GL |
| `database/migrations/2026_01_01_000042_create_bank_transactions_table.php` | Cash |
| `database/migrations/2026_01_01_000043_add_opening_balance_to_bank_accounts.php` | Cash |
| `app/Models/ChartOfAccount.php` | COA |
| `app/Models/JournalEntry.php` | GL |
| `app/Models/JournalEntryItem.php` | GL |
| `app/Models/BankTransaction.php` | Cash |
| `app/Http/Controllers/API/ChartOfAccountsController.php` | COA |
| `app/Http/Controllers/API/JournalEntriesController.php` | GL |
| `app/Http/Controllers/API/CashFlowController.php` | Cash |

### Backend — Modified Files

| File | Change |
|------|--------|
| `routes/api.php` | Add COA, GL, BankTransaction routes |
| `app/Models/BankAccount.php` | Add opening_balance, as_of_date |

### Frontend — New Files

| File | Module |
|------|--------|
| `shared/models/index.ts` (update) | All three modules |
| `shared/services/chart-of-account.service.ts` | COA |
| `shared/services/journal-entry.service.ts` | GL |
| `shared/services/cash-flow.service.ts` | Cash |
| `modules/accounting/accounting.routes.ts` | Accounting group |
| `modules/accounting/chart-of-account-list.component.ts` | COA |
| `modules/accounting/chart-of-account-form.component.ts` | COA |
| `modules/accounting/journal-entry-list.component.ts` | GL |
| `modules/accounting/journal-entry-form.component.ts` | GL |
| `modules/accounting/bank-transaction-list.component.ts` | Cash |
| `modules/accounting/bank-transaction-form.component.ts` | Cash |

### Frontend — Modified Files

| File | Change |
|------|--------|
| `app.routes.ts` | Add `/accounting` route |
| `shared/components/navigation.component.ts` | Add Accounting group with 3 children |

---

## Validation

- TypeScript: `tsc --noEmit` — must pass with zero errors
- Backend route registration verified
- Navigation links verified

---

*Document Version: 3.0.0 | Last Updated: 2025-05-18*
