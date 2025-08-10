dnf install -y 389-ds-base


dscreate interactive

インスタンス名（例: example）
サーバーのLDAPポート（通常389）
管理者DNのパスワード（Directory Manager）
ベースDN（例: dc=example,dc=com）
管理者ユーザー（通常cn=Directory Manager）


/usr/sbin/ns-slapd -D /etc/dirsrv/slapd-test-com -i /var/run/dirsrv/test-com.pid


[root@f33a5b973b27 /]# dsconf test-com plugin show addn
Error: No object exists given the filter criteria: addn (&(&(objectclass=top)(objectclass=nsslapdplugin))(|(cn=addn)(nsslapd-pluginPath=addn)))


[root@f33a5b973b27 ldif]# ldapadd -x -D "cn=Directory Manager" -W -f addn-plugin.ldif
Enter LDAP Password:
adding new entry "cn=addn,cn=plugins,cn=config"



[root@f33a5b973b27 ldif]# ls -la /usr/lib64/dirsrv/plugins/ | grep addn
-rwxr-xr-x 1 root root   23560 Jun 25 01:47 libaddn-plugin.so
[root@f33a5b973b27 ldif]# dsconf test-com plugin show addn
dn: cn=addn,cn=plugins,cn=config
addn_default_domain: test.com
cn: addn
nsslapd-pluginDescription: AD DN Bind Plugin (addn)
nsslapd-pluginEnabled: on
nsslapd-pluginId: addn
nsslapd-pluginInitfunc: addn_init
nsslapd-pluginPath: libaddn-plugin.so
nsslapd-pluginType: preoperation
nsslapd-pluginVendor: 389 Project
nsslapd-pluginVersion: 1.4.0.0
objectClass: top
objectClass: nsSlapdPlugin
objectClass: extensibleObject




[root@f33a5b973b27 ldif]# ldapsearch -x -H ldap://localhost -b "" -s base "(objectClass=*)" namingContexts
# extended LDIF
#
# LDAPv3
# base <> with scope baseObject
# filter: (objectClass=*)
# requesting: namingContexts
#

#
dn:

# search result
search: 2
result: 0 Success

# numResponses: 2
# numEntries: 1



[root@f33a5b973b27 ldif]# dsconf test-com backend create --suffix dc=test,dc=com --be-name userRoot
The database was sucessfully created


[root@f33a5b973b27 test.com]# ldapsearch -x -H ldap://localhost -b "" -s base "(objectClass=*)" namingContexts
# extended LDIF
#
# LDAPv3
# base <> with scope baseObject
# filter: (objectClass=*)
# requesting: namingContexts
#

#
dn:
namingContexts: dc=test,dc=com

# search result
search: 2
result: 0 Success

# numResponses: 2
# numEntries: 1




[root@f33a5b973b27 test.com]# ldapadd -x -D "cn=Directory Manager" -W -f base.ldif
Enter LDAP Password:
adding new entry "dc=test,dc=com"

adding new entry "ou=users,dc=test,dc=com"




[root@f33a5b973b27 test.com]# ldapadd -x -D "cn=Directory Manager" -W -f user.ldif
Enter LDAP Password:
adding new entry "uid=tarou,ou=users,dc=test,dc=com"

[root@f33a5b973b27 test.com]# ldapsearch -x -b "ou=users,dc=test,dc=com" "(uid=tarou)"
# extended LDIF
#
# LDAPv3
# base <ou=users,dc=test,dc=com> with scope subtree
# filter: (uid=tarou)
# requesting: ALL
#

# search result
search: 2
result: 0 Success




[root@f33a5b973b27 test.com]# dsconf test-com backend suffix list
dc=test,dc=com (userroot)





[root@f33a5b973b27 test.com]# dsctl test-com db2ldif userRoot /tmp/dump.ldif
System has not been booted with systemd as init system (PID 1). Can't operate.
Failed to connect to bus: Host is down
[09/Aug/2025:17:23:55.146705029 +0000] - WARN - addn_plugin - addn_init: The use of this plugin violates the LDAPv3 specification RFC4511 section 4.2 BindDN specification. You have been warned ...
[09/Aug/2025:17:23:55.248735884 +0000] - NOTICE - slapd_system_isFIPS - Can not access /proc/sys/crypto/fips_enabled - assuming FIPS is OFF
ldiffile: /tmp/dump.ldif
db2ldif successful





[root@f33a5b973b27 test.com]# ldapsearch -x -D "cn=Directory Manager" -W -b "ou=users,dc=test,dc=com" "(uid=tarou)"
Enter LDAP Password:
# extended LDIF
#
# LDAPv3
# base <ou=users,dc=test,dc=com> with scope subtree
# filter: (uid=tarou)
# requesting: ALL
#

# tarou, users, test.com
dn: uid=tarou,ou=users,dc=test,dc=com
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
objectClass: top
uid: tarou
cn: Tarou Yamada
sn: Yamada
givenName: Tarou
mail: tarou@test.com
userPassword:: e1BCS0RGMi1TSEE1MTJ9MTAwMDAwJEpIOEwreFVtc3BQUndMY3VpaDJqWWxrRWZ
 YM3MvMlRnJE9UVm5wV00vSXUwT3NUWGFRNFhDV0owdVNWN3h4WGF0SXVqYmJ5cW95bk1DU0VvcUQ0
 ZFlsVXcvczA3NGp6SHhtQmFXT2M2c1I2ZWhVRmk5TGs4SjV3PT0=

# search result
search: 2
result: 0 Success

# numResponses: 2
# numEntries: 1






[root@d51837eede02 test.com]# ldapwhoami -x -D "uid=tarou,ou=users,dc=test,dc=com" -w password
^[[A^[[Ddn: uid=tarou,ou=users,dc=test,dc=com
[root@d51837eede02 test.com]# ldapwhoami -x -D "tarou@test.com" -w password
ldap_bind: Invalid credentials (49)


[root@d51837eede02 test.com]# dsconf test plugin show addn
dn: cn=addn,cn=plugins,cn=config
addn_default_domain: test.com
cn: addn
nsslapd-pluginDescription: AD DN Bind Plugin (addn)
nsslapd-pluginEnabled: on
nsslapd-pluginId: addn
nsslapd-pluginInitfunc: addn_init
nsslapd-pluginPath: libaddn-plugin
nsslapd-pluginType: preoperation
nsslapd-pluginVendor: 389 Project
nsslapd-pluginVersion: 1.3.6.0
objectClass: top
objectClass: nsSlapdPlugin
objectClass: extensibleObject





[root@d51837eede02 test.com]# ldapwhoami -x -D "uid=tarou,ou=users,dc=test,dc=com" -w password
dn: uid=tarou,ou=users,dc=test,dc=com
[root@d51837eede02 test.com]# ldapwhoami -x -D "tarou@test.com" -w password
dn: uid=tarou,ou=users,dc=test,dc=com


プラグイン設定後に再起動が必要
