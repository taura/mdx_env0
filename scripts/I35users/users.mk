#
# users.mk --- create taulec group and users
#
include ../common.mk

users_     := $(shell sqlite3 $(db) 'select user from users')
users := $(patsubst %,made/%,$(users_))
slapadd:=slapadd

ifeq ($(node_id),0)
  targets := made_users.csv
else
  targets := 
endif

OK : $(targets)

host_fqdn := $(shell sqlite3 $(db) "select hostname from hosts where node_id=0 and idx=0")
host_dc := $(shell python3 -c "print(','.join([ 'dc=%s' % x for x in '$(host_fqdn)'.split('.') ]))")
host_only := $(shell python3 -c "print('$(host_fqdn)'.split('.')[0])")

ldif/group_template.ldif : ldif/group_template.ldif.template
	sed -e "s/%host_fqdn%/$(host_fqdn)/g" -e "s/%host_dc%/$(host_dc)/g" -e "s/%host_only%/$(host_only)/g" ldif/group_template.ldif.template > ldif/group_template.ldif

ldif/user_template.ldif : ldif/user_template.ldif.template
	sed -e "s/%host_fqdn%/$(host_fqdn)/g" -e "s/%host_dc%/$(host_dc)/g" -e "s/%host_only%/$(host_only)/g" ldif/user_template.ldif.template > ldif/user_template.ldif

made_users.csv : $(users)
	cat $(users) > $@

$(users) : user=$(notdir $@)
$(users) : uid=$(shell    sqlite3 $(db) 'select uid  from users where user="$(user)"')
$(users) : grp=$(shell  sqlite3 $(db) 'select grp  from users where user="$(user)"')
$(users) : gid=$(shell    sqlite3 $(db) 'select gid  from users where user="$(user)"')
$(users) : home=$(shell   sqlite3 $(db) 'select home from users where user="$(user)"')
$(users) : mod=$(shell    sqlite3 $(db) 'select mod  from users where user="$(user)"')
$(users) : db_pwd=$(shell sqlite3 $(db) 'select pwd  from users where user="$(user)"')
$(users) : db_sha_pwd=$(shell sqlite3 $(db) 'select sha_pwd  from users where user="$(user)"')
$(users) : pubkey=$(shell sqlite3 $(db) 'select pubkey from users where user="$(user)"')
# if sha_pwd given in db, leave pwd empty; if db_pwd is given, use it, otherwise generate one
$(users) : pwd=$(shell if test -n "$(db_sha_pwd)" ; then echo "" ; else echo "$(db_pwd)" | grep . || pwgen 8 1; fi)
# if sha_pwd given in db, use it; otherwise sha plain pwd
$(users) : sha_pwd=$(shell echo $(db_sha_pwd) | grep . || slappasswd -s $(pwd))
$(users) : % : ldif/group_template.ldif ldif/user_template.ldif made/created /usr/bin/pwgen
	slapcat -a '(&(cn=$(grp))(objectClass=posixGroup))' | grep dn: || sed -e s/%GROUP%/$(grp)/g -e s/%GID%/$(gid)/g ldif/group_template.ldif | $(slapadd)
	slapcat -a 'uid=$(user)' | grep dn: || sed -e s/%GROUP%/$(grp)/g -e s/%GID%/$(gid)/g -e s/%USER%/$(user)/g -e s/%UID%/$(uid)/g -e s:%HOME%:$(home):g -e s:%SHA_PASSWORD%:$(sha_pwd):g ldif/user_template.ldif | $(slapadd)
	if ! test -d $(home) ; then mkdir -p $(home) -m 0$(mod) ; chown $(uid):$(gid) $(home) ; fi
	./add_pubkey.sh $(home) $(uid) $(gid) "$(pubkey)"
	echo "$(user),$(uid),$(grp),$(gid),$(home),$(mod),$(pwd),$(sha_pwd),$(pubkey)" > $@

/usr/bin/pwgen :
	$(aptinst) pwgen

made/created :
	mkdir -p $@
