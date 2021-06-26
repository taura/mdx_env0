#
# ldap.mk --- configure ldap server/client
#
include ../common.mk

ifeq ($(node_id),0)
  targets := ldap_server ldap_client
else
  targets := ldap_client
endif

OK : $(targets)

host_fqdn := $(shell sqlite3 $(db) "select hostname from hosts where node_id=0 and idx=0")
host_dc := $(shell python3 -c "print(','.join([ 'dc=%s' % x for x in '$(host_fqdn)'.split('.') ]))")
host_only := $(shell python3 -c "print('$(host_fqdn)'.split('.')[0])")

ldif/config.ldif : ldif/config.ldif.template
	sed -e "s/%host_fqdn%/$(host_fqdn)/g" -e "s/%host_dc%/$(host_dc)/g" -e "s/%host_only%/$(host_only)/g" ldif/config.ldif.template > ldif/config.ldif

ldif/dump.ldif : ldif/dump.ldif.template
	sed -e "s/%host_fqdn%/$(host_fqdn)/g" -e "s/%host_dc%/$(host_dc)/g" -e "s/%host_only%/$(host_only)/g" ldif/dump.ldif.template > ldif/dump.ldif

ldap_server : ldif/config.ldif ldif/dump.ldif
	$(aptinst) slapd ldap-utils
	service slapd stop
	rm -rf /etc/ldap/slapd.d
	mkdir -m 700 /etc/ldap/slapd.d
	rm -rf /var/lib/ldap
	mkdir -m 700 /var/lib/ldap
	slapadd -n0 -F /etc/ldap/slapd.d -l ldif/config.ldif
	slapadd -l ldif/dump.ldif
	chown -R openldap:openldap /etc/ldap/slapd.d
	chown -R openldap:openldap /var/lib/ldap
	service slapd start
	touch $@

conf/ldap.conf : conf/ldap.conf.template $(db)
	sed -e "s/%host_fqdn%/$(host_fqdn)/g" -e "s/%host_dc%/$(host_dc)/g" -e "s/%host_only%/$(host_only)/g" conf/ldap.conf.template > conf/ldap.conf

conf/nslcd.conf : conf/nslcd.conf.template $(db)
	sed -e "s/%host_fqdn%/$(host_fqdn)/g" -e "s/%host_dc%/$(host_dc)/g" -e "s/%host_only%/$(host_only)/g" conf/nslcd.conf.template > conf/nslcd.conf

ldap_client : /etc/nsswitch.conf conf/ldap.conf conf/nslcd.conf
	$(aptinst) ldap-utils libpam-ldap libnss-ldap nslcd
	$(inst) conf/ldap.conf /etc/ldap.conf
	$(inst) conf/nslcd.conf /etc/nslcd.conf
	touch $@

/etc/nsswitch.conf : ldap.mk conf/nsswitch.conf
	mkdir -p backup
	cp /etc/nsswitch.conf backup/etc_nsswitch.conf
	$(inst) conf/nsswitch.conf $@

