#
# hostname.mk --- set the hostname
# 
include ../common.mk

OK : /etc/hostname

/etc/hostname :
ifneq ($(hostname),)
	hostname $(hostname)
	echo $(hostname) > /etc/hostname
else
$(warning host of address $(addr) not in the database $(db))
endif
