#!/bin/sh
dsconf localhost backend create --suffix dc=test,dc=com --be-name userroot --create-suffix --create-entries
ldapadd -H ldap://localhost:3389 -D "cn=Directory Manager" -w adminpassword -f 01-base.ldif
ldapadd -H ldap://localhost:3389 -D "cn=Directory Manager" -w adminpassword -f 99userPrincipalName.ldif
ldapadd -H ldap://localhost:3389 -D "cn=Directory Manager" -w adminpassword -f 99user2.ldif
