#
# hostname.mk --- set the hostname
# 
include ../common.mk

OK : /etc/hostname

/etc/hostname : $(db)
ifneq ($(hostname),)
	hostname $(hostname)
	echo $(hostname) > /etc/hostname
else
$(error host of address $(addr) not in the database $(db))
endif
