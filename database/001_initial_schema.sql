-- ==========================================
-- PRODUCTION READY SCHEMA
-- Purchasing System (PostgreSQL)
-- ==========================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- ENUMS
-- ==========================================

CREATE TYPE pr_status AS ENUM (
'DRAFT',
'SUBMITTED',
'APPROVED_L1',
'APPROVED_L2',
'APPROVED_L3',
'REJECTED'
);

CREATE TYPE po_status AS ENUM (
'DRAFT',
'APPROVED',
'SENT',
'CANCELLED'
);

CREATE TYPE approval_status AS ENUM (
'PENDING',
'APPROVED',
'REJECTED'
);

CREATE TYPE outbox_status AS ENUM (
'PENDING',
'SENT',
'FAILED'
);

-- ==========================================
-- MASTER TABLES
-- ==========================================

CREATE TABLE m_role (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
role_name VARCHAR(100) UNIQUE NOT NULL,
description TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP
);

CREATE TABLE m_department (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
department_name VARCHAR(150) NOT NULL,
description TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP
);

CREATE TABLE m_user (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
username VARCHAR(100) UNIQUE NOT NULL,
email VARCHAR(150) UNIQUE NOT NULL,
password_hash TEXT NOT NULL,
full_name VARCHAR(150),
role_id BIGINT NOT NULL,
is_active BOOLEAN DEFAULT TRUE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP,
deleted_at TIMESTAMP,

```
CONSTRAINT fk_user_role
    FOREIGN KEY (role_id)
    REFERENCES m_role(id)
    ON UPDATE CASCADE
```

);

CREATE TABLE m_vendor (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
vendor_code VARCHAR(50) UNIQUE,
vendor_name VARCHAR(200) NOT NULL,
contact_person VARCHAR(150),
phone VARCHAR(50),
email VARCHAR(150),
address TEXT,
is_active BOOLEAN DEFAULT TRUE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP,
deleted_at TIMESTAMP
);

CREATE TABLE m_product (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
product_code VARCHAR(50) UNIQUE,
product_name VARCHAR(200) NOT NULL,
description TEXT,
unit VARCHAR(50),
price NUMERIC(18,2) CHECK (price >= 0),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP
);

-- ==========================================
-- TRANSACTION TABLES
-- ==========================================

CREATE TABLE t_purchase_request (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
request_number VARCHAR(100) UNIQUE NOT NULL,
requested_by BIGINT NOT NULL,
department_id BIGINT NOT NULL,
request_date DATE,
status pr_status NOT NULL DEFAULT 'DRAFT',
notes TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP,

```
CONSTRAINT fk_pr_user
    FOREIGN KEY (requested_by)
    REFERENCES m_user(id),

CONSTRAINT fk_pr_department
    FOREIGN KEY (department_id)
    REFERENCES m_department(id)
```

);

CREATE TABLE t_purchase_request_item (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
purchase_request_id BIGINT NOT NULL,
product_id BIGINT NOT NULL,
quantity INTEGER CHECK (quantity > 0),
estimated_price NUMERIC(18,2) CHECK (estimated_price >= 0),
notes TEXT,

```
CONSTRAINT fk_pr_item_pr
    FOREIGN KEY (purchase_request_id)
    REFERENCES t_purchase_request(id)
    ON DELETE CASCADE,

CONSTRAINT fk_pr_item_product
    FOREIGN KEY (product_id)
    REFERENCES m_product(id)
```

);

CREATE TABLE t_purchase_order (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
po_number VARCHAR(100) UNIQUE NOT NULL,
vendor_id BIGINT NOT NULL,
purchase_request_id BIGINT,
order_date DATE,
status po_status NOT NULL DEFAULT 'DRAFT',
total_amount NUMERIC(18,2),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP,

```
CONSTRAINT fk_po_vendor
    FOREIGN KEY (vendor_id)
    REFERENCES m_vendor(id),

CONSTRAINT fk_po_pr
    FOREIGN KEY (purchase_request_id)
    REFERENCES t_purchase_request(id)
```

);

CREATE TABLE t_purchase_order_item (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
purchase_order_id BIGINT NOT NULL,
product_id BIGINT NOT NULL,
quantity INTEGER CHECK (quantity > 0),
price NUMERIC(18,2) CHECK (price >= 0),
subtotal NUMERIC(18,2),

```
CONSTRAINT fk_po_item_po
    FOREIGN KEY (purchase_order_id)
    REFERENCES t_purchase_order(id)
    ON DELETE CASCADE,

CONSTRAINT fk_po_item_product
    FOREIGN KEY (product_id)
    REFERENCES m_product(id)
```

);

CREATE TABLE t_goods_receipt (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
receipt_number VARCHAR(100) UNIQUE NOT NULL,
purchase_order_id BIGINT NOT NULL,
received_by BIGINT NOT NULL,
receipt_date DATE,
notes TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

```
CONSTRAINT fk_receipt_po
    FOREIGN KEY (purchase_order_id)
    REFERENCES t_purchase_order(id),

CONSTRAINT fk_receipt_user
    FOREIGN KEY (received_by)
    REFERENCES m_user(id)
```

);

CREATE TABLE t_goods_receipt_item (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
goods_receipt_id BIGINT NOT NULL,
product_id BIGINT NOT NULL,
quantity_received INTEGER CHECK (quantity_received >= 0),
condition_note TEXT,

```
CONSTRAINT fk_gr_item_gr
    FOREIGN KEY (goods_receipt_id)
    REFERENCES t_goods_receipt(id)
    ON DELETE CASCADE,

CONSTRAINT fk_gr_item_product
    FOREIGN KEY (product_id)
    REFERENCES m_product(id)
```

);

-- ==========================================
-- APPROVAL WORKFLOW (CRITICAL)
-- ==========================================

CREATE TABLE t_approval (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
reference_type VARCHAR(50) NOT NULL,
reference_id BIGINT NOT NULL,
approver_id BIGINT NOT NULL,
approval_level INTEGER NOT NULL,
status approval_status DEFAULT 'PENDING',
notes TEXT,
approved_at TIMESTAMP,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

```
CONSTRAINT fk_approval_user
    FOREIGN KEY (approver_id)
    REFERENCES m_user(id)
```

);

-- ==========================================
-- INVENTORY
-- ==========================================

CREATE TABLE t_inventory (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
product_id BIGINT NOT NULL,
location VARCHAR(100),
quantity INTEGER DEFAULT 0,
updated_at TIMESTAMP,

```
CONSTRAINT fk_inventory_product
    FOREIGN KEY (product_id)
    REFERENCES m_product(id)
```

);

-- ==========================================
-- NOTIFICATION
-- ==========================================

CREATE TABLE t_notification (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
user_id BIGINT,
title VARCHAR(200),
message TEXT,
is_read BOOLEAN DEFAULT FALSE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

```
CONSTRAINT fk_notification_user
    FOREIGN KEY (user_id)
    REFERENCES m_user(id)
```

);

-- ==========================================
-- OUTBOX (FOR KAFKA)
-- ==========================================

CREATE TABLE t_outbox_event (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
aggregate_type VARCHAR(100),
aggregate_id VARCHAR(100),
event_type VARCHAR(100),
payload JSONB,
status outbox_status DEFAULT 'PENDING',
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- AUDIT LOG
-- ==========================================

CREATE TABLE t_audit_log (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
user_id BIGINT,
username VARCHAR(100),
service_name VARCHAR(100),
action VARCHAR(150),
entity_name VARCHAR(150),
entity_id VARCHAR(100),
description TEXT,
ip_address VARCHAR(100),
user_agent TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE t_audit_log_detail (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
audit_log_id BIGINT,
field_name VARCHAR(150),
old_value TEXT,
new_value TEXT,

```
CONSTRAINT fk_audit_detail_log
    FOREIGN KEY (audit_log_id)
    REFERENCES t_audit_log(id)
    ON DELETE CASCADE
```

);

-- ==========================================
-- INDEXES
-- ==========================================

CREATE INDEX idx_pr_status ON t_purchase_request(status);
CREATE INDEX idx_po_status ON t_purchase_order(status);
CREATE INDEX idx_pr_user ON t_purchase_request(requested_by);
CREATE INDEX idx_po_vendor ON t_purchase_order(vendor_id);
CREATE INDEX idx_inventory_product ON t_inventory(product_id);
CREATE INDEX idx_outbox_status ON t_outbox_event(status);
CREATE INDEX idx_audit_user ON t_audit_log(user_id);
