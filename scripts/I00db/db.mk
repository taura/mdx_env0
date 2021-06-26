#
# db.mk --- make a database of hosts and users
# 
include ../common.mk

OK : $(db)

$(db) : $(db_dir)/hosts.csv $(db_dir)/users.csv
	rm -f $(db)
	echo -n | sqlite3 -separator , -cmd ".import $(db_dir)/hosts.csv hosts" $(db).bak
	echo -n | sqlite3 -separator , -cmd ".import $(db_dir)/users.csv users" $(db).bak
	mv $(db).bak $(db)
