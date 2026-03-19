# kafka-topics-final.txt

# ==========================================

# USER & AUTH EVENTS

# ==========================================

auth.user.created
auth.user.created.reply

auth.user.updated
auth.user.updated.reply

auth.user.login.success
auth.user.login.failed

# ==========================================

# VENDOR EVENTS

# ==========================================

vendor.created
vendor.created.reply

vendor.updated
vendor.updated.reply

vendor.deactivated

# ==========================================

# PURCHASE REQUEST EVENTS

# ==========================================

purchasing.pr.created
purchasing.pr.created.reply

purchasing.pr.updated
purchasing.pr.updated.reply

purchasing.pr.submitted

purchasing.pr.approved.level1
purchasing.pr.approved.level1.reply

purchasing.pr.approved.level2
purchasing.pr.approved.level2.reply

purchasing.pr.approved.level3
purchasing.pr.approved.level3.reply

purchasing.pr.rejected

# ==========================================

# PURCHASE ORDER EVENTS

# ==========================================

purchasing.po.created
purchasing.po.created.reply

purchasing.po.approved
purchasing.po.approved.reply

purchasing.po.sent.to.vendor

purchasing.po.cancelled

# ==========================================

# GOODS RECEIPT EVENTS

# ==========================================

inventory.goods.received
inventory.goods.received.reply

inventory.goods.returned

# ==========================================

# NOTIFICATION EVENTS

# ==========================================

notification.send.email
notification.send.system

# ==========================================

# AUDIT EVENTS

# ==========================================

audit.log.activity
audit.log.data.change

# ==========================================

# SYSTEM EVENTS

# ==========================================

system.error
system.warning

system.integration.sap
system.integration.sap.reply
