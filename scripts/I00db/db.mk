#
# db.mk --- make a database of hosts and users
# 
include ../common.mk

OK : $(db)

$(db) : $(host_users_dir)/hosts.csv $(host_users_dir)/users.csv
	rm -f $(db)
	echo -n | sqlite3 -separator , -cmd ".import $(host_users_dir)/hosts.csv hosts" $(db).bak
	echo -n | sqlite3 -separator , -cmd ".import $(host_users_dir)/users.csv users" $(db).bak
	mv $(db).bak $(db)
