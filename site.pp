#Samba4 DC  and libnss-ldap installation. Remember you must change the ldap.conf file to suit your needs!
#All this applies to Ubuntu 14.04 only!
#BEFORE YOU RUN THIS READ NEXT LINE!
#Please make sure you add user_xattr,acl,barrier=1, after the "ext4" of your root file system and any other file systems that you are using for Samba shares!

exec { "apt-get update":
    command => "/usr/bin/apt-get update",

}
Exec["apt-get update"] -> Package <| |>

Package { ensure => "installed" }

package { "acl":}
package { "samba": }
package { "krb5-user": }
package { "smbclient":   }
package { "libnss-ldap": }

exec { 'mount acl':
  command => '/bin/mount -a',
}

exec { 'remove smb.conf':
  command => '/bin/rm /etc/samba/smb.conf',
}
#Change the below provisioning command to your needs!
exec { 'provision samba4':
  command => '/usr/bin/samba-tool domain provision --use-rfc2307 --realm=chu.nz --domain=chu --adminpass=Victor123 --server-role=dc --dns-backend=SAMBA_INTERNAL',
  path    => ['/usr/bin/samba-tool'],
  timeout     => 0,
}
exec { 'set noexpiry':
  command => '/usr/bin/samba-tool user setexpiry administrator --noexpiry',
}


service {
    'samba':
        ensure => true,
        enable => true,
        require => Package['samba']
}
Package['acl'] -> Package['samba'] -> Exec['mount acl'] -> Exec['remove smb.conf'] -> Exec['provision samba4'] -> Exec['set noexpiry'] -> Service['samba']

file { "/etc/ldap.conf":
    ensure => file,
    owner  => root,
    group  => root,
    mode   => 644,
    source => "puppet:///files/ldap.conf",
}
