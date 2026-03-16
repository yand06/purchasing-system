-- ==========================================
-- Purchasing System Initial Database Schema
-- PostgreSQL
-- ==========================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- MASTER TABLES
-- ==========================================

CREATE TABLE m_role (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
role_name VARCHAR(100) UNIQUE NOT NULL,
description TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE m_department (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
department_name VARCHAR(150) NOT NULL,
description TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE m_user (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
username VARCHAR(100) UNIQUE NOT NULL,
email VARCHAR(150) UNIQUE NOT NULL,
password_hash TEXT NOT NULL,
full_name VARCHAR(150),
role_id BIGINT,
is_active BOOLEAN DEFAULT TRUE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
CONSTRAINT fk_user_role
FOREIGN KEY (role_id)
REFERENCES m_role(id)
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
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE m_product (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
product_code VARCHAR(50) UNIQUE,
product_name VARCHAR(200) NOT NULL,
description TEXT,
unit VARCHAR(50),
price NUMERIC(18,2),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE m_notification_template (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
template_name VARCHAR(150),
subject VARCHAR(200),
content TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- TRANSACTION TABLES
-- ==========================================

CREATE TABLE t_purchase_request (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
request_number VARCHAR(100) UNIQUE,
requested_by BIGINT,
department_id BIGINT,
request_date DATE,
status VARCHAR(50),
notes TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
CONSTRAINT fk_pr_user
FOREIGN KEY (requested_by)
REFERENCES m_user(id),
CONSTRAINT fk_pr_department
FOREIGN KEY (department_id)
REFERENCES m_department(id)
);

CREATE TABLE t_purchase_request_item (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
purchase_request_id BIGINT,
product_id BIGINT,
quantity INTEGER,
estimated_price NUMERIC(18,2),
notes TEXT,
CONSTRAINT fk_pr_item_pr
FOREIGN KEY (purchase_request_id)
REFERENCES t_purchase_request(id),
CONSTRAINT fk_pr_item_product
FOREIGN KEY (product_id)
REFERENCES m_product(id)
);

CREATE TABLE t_purchase_order (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
po_number VARCHAR(100) UNIQUE,
vendor_id BIGINT,
purchase_request_id BIGINT,
order_date DATE,
status VARCHAR(50),
total_amount NUMERIC(18,2),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
CONSTRAINT fk_po_vendor
FOREIGN KEY (vendor_id)
REFERENCES m_vendor(id),
CONSTRAINT fk_po_pr
FOREIGN KEY (purchase_request_id)
REFERENCES t_purchase_request(id)
);

CREATE TABLE t_purchase_order_item (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
purchase_order_id BIGINT,
product_id BIGINT,
quantity INTEGER,
price NUMERIC(18,2),
subtotal NUMERIC(18,2),
CONSTRAINT fk_po_item_po
FOREIGN KEY (purchase_order_id)
REFERENCES t_purchase_order(id),
CONSTRAINT fk_po_item_product
FOREIGN KEY (product_id)
REFERENCES m_product(id)
);

CREATE TABLE t_goods_receipt (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
receipt_number VARCHAR(100) UNIQUE,
purchase_order_id BIGINT,
received_by BIGINT,
receipt_date DATE,
notes TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
CONSTRAINT fk_receipt_po
FOREIGN KEY (purchase_order_id)
REFERENCES t_purchase_order(id),
CONSTRAINT fk_receipt_user
FOREIGN KEY (received_by)
REFERENCES m_user(id)
);

CREATE TABLE t_goods_receipt_item (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
goods_receipt_id BIGINT,
product_id BIGINT,
quantity_received INTEGER,
condition_note TEXT,
CONSTRAINT fk_gr_item_gr
FOREIGN KEY (goods_receipt_id)
REFERENCES t_goods_receipt(id),
CONSTRAINT fk_gr_item_product
FOREIGN KEY (product_id)
REFERENCES m_product(id)
);

CREATE TABLE t_notification (
id BIGSERIAL PRIMARY KEY,
idf UUID NOT NULL UNIQUE,
user_id BIGINT,
title VARCHAR(200),
message TEXT,
is_read BOOLEAN DEFAULT FALSE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
CONSTRAINT fk_notification_user
FOREIGN KEY (user_id)
REFERENCES m_user(id)
);

-- ==========================================
-- INDEXES
-- ==========================================

CREATE INDEX idx_vendor_name
ON m_vendor(vendor_name);

CREATE INDEX idx_product_name
ON m_product(product_name);

CREATE INDEX idx_po_vendor
ON t_purchase_order(vendor_id);

CREATE INDEX idx_pr_user
ON t_purchase_request(requested_by);

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

    CONSTRAINT fk_audit_detail_log
        FOREIGN KEY (audit_log_id)
        REFERENCES t_audit_log(id)
);

CREATE TABLE t_system_log (
    id BIGSERIAL PRIMARY KEY,
    idf UUID NOT NULL UNIQUE,

    service_name VARCHAR(150),

    log_level VARCHAR(20),
    message TEXT,

    stack_trace TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_user
ON t_audit_log(user_id);

CREATE INDEX idx_audit_service
ON t_audit_log(service_name);

CREATE INDEX idx_audit_entity
ON t_audit_log(entity_name);

CREATE INDEX idx_system_log_level
ON t_system_log(log_level);