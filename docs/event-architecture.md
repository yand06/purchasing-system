# kafka-topics

# ==========================================

# Purchasing System - Kafka Topic Design

# ==========================================

# USER & AUTH EVENTS

auth.user.created
auth.user.updated
auth.user.login.success
auth.user.login.failed

# VENDOR EVENTS

vendor.created
vendor.updated
vendor.deactivated

# PURCHASE REQUEST EVENTS

purchasing.pr.created
purchasing.pr.updated
purchasing.pr.submitted
purchasing.pr.approved.level1
purchasing.pr.approved.level2
purchasing.pr.approved.level3
purchasing.pr.rejected

# PURCHASE ORDER EVENTS

purchasing.po.created
purchasing.po.approved
purchasing.po.sent.to.vendor
purchasing.po.cancelled

# GOODS RECEIPT EVENTS

inventory.goods.received
inventory.goods.returned

# NOTIFICATION EVENTS

notification.send.email
notification.send.system

# AUDIT EVENTS

audit.log.activity
audit.log.data.change

# SYSTEM EVENTS

system.error
system.warning
system.integration.sap


Example reader:
purchasing
 ├─ pr
 │   ├─ created
 │   └─ approved
 └─ po
     └─ created