#
# hosts.mk --- generate /etc/hosts
#

include ../common.mk

OK : /etc/hosts

/etc/hosts : $(db)
	sqlite3 -separator " " $(db) 'select ip_addr,group_concat(hostname, " ") from hosts' > hosts
	$(kv_merge) /etc/hosts hosts > new_etc_hosts
	$(inst) new_etc_hosts /etc/hosts
