# Audit Event Flow - Purchasing System

## Overview

Audit logging dilakukan menggunakan event-driven architecture melalui Kafka.
Semua service akan mengirimkan event aktivitas ke Kafka dan logger-service
akan mengonsumsi event tersebut untuk disimpan ke database audit trail.

---

## Service yang Terlibat

* api-gateway
* auth-service
* purchasing-service
* vendor-service
* notification-service
* logger-service

---

## Flow Umum

1. User melakukan aksi di sistem
2. Service utama memproses request
3. Service mengirim event ke Kafka
4. Kafka menyimpan event dalam topic
5. logger-service mengonsumsi event
6. logger-service menyimpan data ke tabel audit

---

## Contoh Flow: Create Purchase Request

User → API Gateway → Purchasing Service

Purchasing Service:

* menyimpan data purchase request
* publish event ke Kafka

Topic:
purchasing.pr.created

Event dikonsumsi oleh:

* logger-service
* notification-service (opsional)

logger-service:

* menyimpan aktivitas ke tabel t_audit_log
* jika ada perubahan data → t_audit_log_detail

notification-service:

* mengirim notifikasi approval ke manager

---

## Contoh Flow: Approve Purchase Request

Manager → API Gateway → Purchasing Service

Purchasing Service:

* update status PR
* publish event

Topic:
purchasing.pr.approved.level1

Event dikonsumsi oleh:

* logger-service
* notification-service

---

## Audit Storage

Logger service akan menyimpan:

Table:
t_audit_log

Data:

* user
* action
* entity
* timestamp
* service source

Jika terjadi perubahan data:

Table:
t_audit_log_detail

Data:

* field_name
* old_value
* new_value

---

## Tujuan Arsitektur Ini

1. Memisahkan audit dari business logic
2. Mengurangi coupling antar service
3. Mempermudah compliance dan audit
4. Memungkinkan monitoring aktivitas sistem secara real-time
