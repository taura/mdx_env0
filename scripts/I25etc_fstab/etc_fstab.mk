#
# fstab.mk --- generate /etc/fstab and mount file systems
#

include ../common.mk
ifeq ($(node_id),0)
  fstab:=fstab_server
else
  fstab:=fstab_client
endif

nfs_server := $(shell sqlite3 $(db) "select hostname from hosts where node_id=0 and idx=0")

OK : /etc/fstab

/etc/fstab : $(fstab)
	$(kv_merge) /etc/fstab $(fstab) | sed s/%nfs_server%/$(nfs_server)/g > new_etc_fstab
	$(inst) new_etc_fstab /etc/fstab
	mount -a
