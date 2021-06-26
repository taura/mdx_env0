#
# export.mk --- generate /etc/exports on the master
#
include ../common.mk
ifeq ($(node_id),0)
  targets:=exports
else
  targets:=
endif
clients:=$(shell sqlite3 $(db) "select distinct ip_addr from hosts")

OK : $(targets)

exports : /etc/exports

/etc/exports : $(db)
	(echo -n "/home " ; for c in $(clients); do echo -n "$$c(rw,async,no_root_squash,no_subtree_check) "; done ; echo "") > add_exports 
	$(kv_merge) /etc/exports add_exports > new_etc_exports
	$(inst) new_etc_exports /etc/exports
	exportfs -a

