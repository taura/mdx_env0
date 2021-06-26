#
# nfs.mk --- configure nfs server/client
#

include ../common.mk


ifeq ($(node_id),0)
  targets:=nfs_common nfs_server
else
  targets:=nfs_common
endif

OK : $(targets)

nfs_common :
	$(aptinst) nfs-common
	touch $@

nfs_server :
	$(aptinst) nfs-kernel-server
	touch $@
