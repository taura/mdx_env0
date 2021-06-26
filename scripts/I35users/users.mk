#
# users.mk --- create taulec group and users
#
include ../common.mk

users_     := $(shell sqlite3 $(db) 'select user from users')
users := $(patsubst %,made/%,$(users_))
slapadd:=slapadd

ifeq ($(node_id),0)
  targets := make_users
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

make_users : $(users)
	touch $@

$(users) : user=$(notdir $@)
$(users) : uid=$(shell    sqlite3 $(db) 'select uid  from users where user="$(user)"')
$(users) : grp=$(shell  sqlite3 $(db) 'select grp  from users where user="$(user)"')
$(users) : gid=$(shell    sqlite3 $(db) 'select gid  from users where user="$(user)"')
$(users) : home=$(shell   sqlite3 $(db) 'select home from users where user="$(user)"')
$(users) : mod=$(shell    sqlite3 $(db) 'select mod  from users where user="$(user)"')
$(users) : db_pwd=$(shell sqlite3 $(db) 'select pwd  from users where user="$(user)"')
$(users) : gen_pwd=$(shell pwgen 8 1)
$(users) : pwd=$(shell if test -z "$(db_pwd)" ; then echo $(gen_pwd); else echo $(db_pwd); fi)
$(users) : sha_pwd=$(shell slappasswd -s $(pwd))
$(users) : % : ldif/group_template.ldif ldif/user_template.ldif made/created /usr/bin/pwgen
	slapcat -a '(&(cn=$(grp))(objectClass=posixGroup))' | grep dn: || sed -e s/%GROUP%/$(grp)/g -e s/%GID%/$(gid)/g ldif/group_template.ldif | $(slapadd)
	slapcat -a 'uid=$(user)' | grep dn: || sed -e s/%GROUP%/$(grp)/g -e s/%GID%/$(gid)/g -e s/%USER%/$(user)/g -e s/%UID%/$(uid)/g -e s:%HOME%:$(home):g -e s:%SHA_PASSWORD%:$(sha_pwd):g ldif/user_template.ldif | $(slapadd)
	mkdir -p $(home)
	chmod 0$(mod) $(home)
	chown $(uid):$(gid) $(home)
	echo "$(user),$(uid),$(grp),$(gid),$(home),$(mod),$(pwd)" > $@

/usr/bin/pwgen :
	$(aptinst) pwgen

made/created :
	mkdir -p $@