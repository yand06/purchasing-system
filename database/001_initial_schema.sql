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
role_id BIGSERIAL PRIMARY KEY,
role_idf UUID NOT NULL UNIQUE,
role_name VARCHAR(100) UNIQUE NOT NULL,
role_description TEXT,
role_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
role_updated_at TIMESTAMP
);

CREATE TABLE m_department (
department_id BIGSERIAL PRIMARY KEY,
department_idf UUID NOT NULL UNIQUE,
department_name VARCHAR(150) NOT NULL,
department_description TEXT,
department_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
department_updated_at TIMESTAMP
);

CREATE TABLE m_user (
user_id BIGSERIAL PRIMARY KEY,
user_idf UUID NOT NULL UNIQUE,
user_username VARCHAR(100) UNIQUE NOT NULL,
user_email VARCHAR(150) UNIQUE NOT NULL,
user_password_hash TEXT NOT NULL,
user_full_name VARCHAR(150),
user_role_id BIGINT NOT NULL,
user_is_active BOOLEAN DEFAULT TRUE,
user_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
user_updated_at TIMESTAMP,
user_deleted_at TIMESTAMP,

```
CONSTRAINT fk_user_role
    FOREIGN KEY (user_role_id)
    REFERENCES m_role(role_id)
    ON UPDATE CASCADE
```

);

CREATE TABLE m_vendor (
vendor_id BIGSERIAL PRIMARY KEY,
vendor_idf UUID NOT NULL UNIQUE,
vendor_vendor_code VARCHAR(50) UNIQUE,
vendor_name VARCHAR(200) NOT NULL,
vendor_contact_person VARCHAR(150),
vendor_phone VARCHAR(50),
vendor_email VARCHAR(150),
vendor_address TEXT,
vendor_is_active BOOLEAN DEFAULT TRUE,
vendor_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
vendor_updated_at TIMESTAMP,
vendor_deleted_at TIMESTAMP
);

CREATE TABLE m_product (
product_id BIGSERIAL PRIMARY KEY,
product_idf UUID NOT NULL UNIQUE,
product_code VARCHAR(50) UNIQUE,
product_name VARCHAR(200) NOT NULL,
product_description TEXT,
product_unit VARCHAR(50),
product_price NUMERIC(18,2) CHECK (price >= 0),
product_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
product_updated_at TIMESTAMP
);

-- ==========================================
-- TRANSACTION TABLES
-- ==========================================

CREATE TABLE t_purchase_request (
purchase_request_id BIGSERIAL PRIMARY KEY,
purchase_request_idf UUID NOT NULL UNIQUE,
purchase_request_request_number VARCHAR(100) UNIQUE NOT NULL,
purchase_request_requested_by BIGINT NOT NULL,
purchase_request_department_id BIGINT NOT NULL,
purchase_request_request_date DATE,
purchase_request_status NOT NULL DEFAULT 'DRAFT',
purchase_request_notes TEXT,
purchase_request_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
purchase_request_updated_at TIMESTAMP,

```
CONSTRAINT fk_pr_user
    FOREIGN KEY (purchase_request_requested_by)
    REFERENCES m_user(user_id),

CONSTRAINT fk_pr_department
    FOREIGN KEY (purchase_request_department_id)
    REFERENCES m_department(department_id)
```

);

CREATE TABLE t_purchase_request_item (
purchase_request_item_id BIGSERIAL PRIMARY KEY,
purchase_request_item_idf UUID NOT NULL UNIQUE,
purchase_request_item_purchase_request_id BIGINT NOT NULL,
purchase_request_item_product_id BIGINT NOT NULL,
purchase_request_item_quantity INTEGER CHECK (quantity > 0),
purchase_request_item_estimated_price NUMERIC(18,2) CHECK (estimated_price >= 0),
purchase_request_item_notes TEXT,

```
CONSTRAINT fk_pr_item_pr
    FOREIGN KEY (purchase_request_item_purchase_request_id)
    REFERENCES t_purchase_request(purchase_request_id)
    ON DELETE CASCADE,

CONSTRAINT fk_pr_item_product
    FOREIGN KEY (purchase_request_item_product_id)
    REFERENCES m_product(product_id)
```

);

CREATE TABLE t_purchase_order (
purchase_order_id BIGSERIAL PRIMARY KEY,
purchase_order_idf UUID NOT NULL UNIQUE,
purchase_order_po_number VARCHAR(100) UNIQUE NOT NULL,
purchase_order_vendor_id BIGINT NOT NULL,
purchase_order_purchase_request_id BIGINT,
purchase_order_order_date DATE,
purchase_order_status NOT NULL DEFAULT 'DRAFT',
purchase_order_total_amount NUMERIC(18,2),
purchase_order_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
purchase_order_updated_at TIMESTAMP,

```
CONSTRAINT fk_po_vendor
    FOREIGN KEY (purchase_order_vendor_id)
    REFERENCES m_vendor(vendor_id),

CONSTRAINT fk_po_pr
    FOREIGN KEY (purchase_order_purchase_request_id)
    REFERENCES t_purchase_request(purchase_request_id)
```

);

CREATE TABLE t_purchase_order_item (
purchase_order_item_id BIGSERIAL PRIMARY KEY,
purchase_order_item_idf UUID NOT NULL UNIQUE,
purchase_order_item_purchase_order_id BIGINT NOT NULL,
purchase_order_item_product_id BIGINT NOT NULL,
purchase_order_item_quantity INTEGER CHECK (quantity > 0),
purchase_order_item_price NUMERIC(18,2) CHECK (price >= 0),
purchase_order_item_subtotal NUMERIC(18,2),

```
CONSTRAINT fk_po_item_po
    FOREIGN KEY (purchase_order_item_purchase_order_id)
    REFERENCES t_purchase_order(purchase_order_id)
    ON DELETE CASCADE,

CONSTRAINT fk_po_item_product
    FOREIGN KEY (purchase_order_item_product_id)
    REFERENCES m_product(product_id)
```

);

CREATE TABLE t_goods_receipt (
goods_receipt_id BIGSERIAL PRIMARY KEY,
goods_receipt_idf UUID NOT NULL UNIQUE,
goods_receipt_receipt_number VARCHAR(100) UNIQUE NOT NULL,
goods_receipt_purchase_order_id BIGINT NOT NULL,
goods_receipt_received_by BIGINT NOT NULL,
goods_receipt_receipt_date DATE,
goods_receipt_notes TEXT,
goods_receipt_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

```
CONSTRAINT fk_receipt_po
    FOREIGN KEY (goods_receipt_purchase_order_id)
    REFERENCES t_purchase_order(purchase_order_id),

CONSTRAINT fk_receipt_user
    FOREIGN KEY (goods_receipt_received_by)
    REFERENCES m_user(user_id)
```

);

CREATE TABLE t_goods_receipt_item (
goods_receipt_item_id BIGSERIAL PRIMARY KEY,
goods_receipt_item_idf UUID NOT NULL UNIQUE,
goods_receipt_item_goods_receipt_id BIGINT NOT NULL,
goods_receipt_item_product_id BIGINT NOT NULL,
goods_receipt_item_quantity_received INTEGER CHECK (quantity_received >= 0),
goods_receipt_item_condition_note TEXT,

```
CONSTRAINT fk_gr_item_gr
    FOREIGN KEY (goods_receipt_item_goods_receipt_id)
    REFERENCES t_goods_receipt(goods_receipt_id)
    ON DELETE CASCADE,

CONSTRAINT fk_gr_item_product
    FOREIGN KEY (goods_receipt_item_product_id)
    REFERENCES m_product(product_id)
```

);

-- ==========================================
-- APPROVAL WORKFLOW (CRITICAL)
-- ==========================================

CREATE TABLE t_approval (
approval_id BIGSERIAL PRIMARY KEY,
approval_idf UUID NOT NULL UNIQUE,
approval_reference_type VARCHAR(50) NOT NULL,
approval_reference_id BIGINT NOT NULL,
approval_approver_id BIGINT NOT NULL,
approval_level INTEGER NOT NULL,
approval_status DEFAULT 'PENDING',
approval_notes TEXT,
approval_approved_at TIMESTAMP,
approval_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

```
CONSTRAINT fk_approval_user
    FOREIGN KEY (approval_approver_id)
    REFERENCES m_user(user_id)
```

);

-- ==========================================
-- INVENTORY
-- ==========================================

CREATE TABLE t_inventory (
inventory_id BIGSERIAL PRIMARY KEY,
inventory_idf UUID NOT NULL UNIQUE,
inventory_product_id BIGINT NOT NULL,
inventory_location VARCHAR(100),
inventory_quantity INTEGER DEFAULT 0,
inventory_updated_at TIMESTAMP,

```
CONSTRAINT fk_inventory_product
    FOREIGN KEY (inventory_product_id)
    REFERENCES m_product(product_id)
```

);

-- ==========================================
-- NOTIFICATION
-- ==========================================

CREATE TABLE t_notification (
notification_id BIGSERIAL PRIMARY KEY,
notification_idf UUID NOT NULL UNIQUE,
notification_user_id BIGINT,
notification_title VARCHAR(200),
notification_message TEXT,
notification_is_read BOOLEAN DEFAULT FALSE,
notification_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

```
CONSTRAINT fk_notification_user
    FOREIGN KEY (notification_user_id)
    REFERENCES m_user(user_id)
```

);

-- ==========================================
-- OUTBOX (FOR KAFKA)
-- ==========================================

CREATE TABLE t_outbox_event (
outbox_event_id BIGSERIAL PRIMARY KEY,
outbox_event_idf UUID NOT NULL UNIQUE,
outbox_event_aggregate_type VARCHAR(100),
outbox_event_aggregate_id VARCHAR(100),
outbox_event_type VARCHAR(100),
outbox_event_payload JSONB,
outbox_event_status DEFAULT 'PENDING',
outbox_event_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- AUDIT LOG
-- ==========================================

CREATE TABLE t_audit_log (
audit_log_id BIGSERIAL PRIMARY KEY,
audit_log_idf UUID NOT NULL UNIQUE,
audit_log_user_id BIGINT,
audit_log_username VARCHAR(100),
audit_log_service_name VARCHAR(100),
audit_log_action VARCHAR(150),
audit_log_entity_name VARCHAR(150),
audit_log_entity_id VARCHAR(100),
audit_log_description TEXT,
audit_log_ip_address VARCHAR(100),
audit_log_user_agent TEXT,
audit_log_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE t_audit_log_detail (
audit_log_detail_id BIGSERIAL PRIMARY KEY,
audit_log_detail_idf UUID NOT NULL UNIQUE,
audit_log_detail_audit_log_id BIGINT,
audit_log_detail_field_name VARCHAR(150),
audit_log_detail_old_value TEXT,
audit_log_detail_new_value TEXT,

```
CONSTRAINT fk_audit_detail_log
    FOREIGN KEY (audit_log_detail_audit_log_id)
    REFERENCES t_audit_log(audit_log_id)
    ON DELETE CASCADE
```

);

-- ==========================================
-- INDEXES
-- ==========================================

CREATE INDEX idx_pr_status ON t_purchase_request(purchase_request_status);
CREATE INDEX idx_po_status ON t_purchase_order(purchase_order_status);
CREATE INDEX idx_pr_user ON t_purchase_request(purchase_request_requested_by);
CREATE INDEX idx_po_vendor ON t_purchase_order(purchase_order_vendor_id);
CREATE INDEX idx_inventory_product ON t_inventory(inventory_product_id);
CREATE INDEX idx_outbox_status ON t_outbox_event(outbox_event_status);
CREATE INDEX idx_audit_user ON t_audit_log(audit_log_user_id);
