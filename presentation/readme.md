# TDDI41 - docs

> frabe808, carlo826

Innehåller alla ändringar gjorde för varje labb och motivering till varför.

## NET

### Setting the hostname
`etc/hostname` -> server, gw, client-1, client-2

`etc/hosts` -> 127.0.0.1 localhost

`etc/hosts` -> 10.0.0.x xxxx.student.ida.liu.se

### Basic network connectivity

`etc/network/interfaces` -> Vi la till korrekt config för varje interface.
I uppgiften var interfaces namn: eth0 och eth1, dock verkade
vår version av debian ha andra namn ens3 och ens4

`ip addroute default via 10.0.0.0.1 dev ens3` -> La till default route till interface
ens3 på gatewayn.

### Name resolution

`etc/nsswitch.conf` -> Vi la till första versionen för alla. (files dns)


### Router configuration
Vi använder [iptables](https://www.howtoforge.com/nat_iptables) för att configurera 
IP Forwarding (på vårat inåt riktade interface) och [Masquerading](https://www.linux.com/tutorials/what-ip-masquerading-and-when-it-use/) på det utåt riktade.

`iptables --table nat --append POSTROUTING --out-interface ens3 -j MASQUERADE`

`iptables --append FORWARD --in-interface ens4 -j ACCEPT`

## DNS

### DNS Security Requirements:
The DNS config files (server):
```python
etc/bind/named.conf.options // options
etc/bind/named.conf.local   // zones
etc/bind/named.conf         // main
etc/bind/keys/*             // keys
etc/bind/zones/*            // keys

```

#### Respond authoritatively to all non-recursive queries for names in the zones you are authoritative for.
`etc/bind/named.conf.options`
```
allow_query { any; }
allow_transfer { none; }
auth-nxdomain no;
```
Responds authoritatively to all queries, how it handles recursive queries are
explained below. Also does not allow transfer of it's zone files & and only
responds authoritatively on valid addresses.

#### Respond to all recursive queries from the hosts in your own network.
#### Not respond to any recursive queries from any outside hosts.
`etc/bind/named.conf`
```
acl "trusted" {
  127.0.0.1;
  10.0.0.0/24;
};
```
`etc/bind/named.conf.options`
```
recursion yes;
allow-recursion { trusted; }
```
We define an ACL "trusted" that covers all hosts within our network.
Recursion is only allowed from that group. 

#### Apart from the queries in (a), it should not respond to any queries from any outside host.
`etc/bind/named.conf.options`
```
allow-query-cache { trusted; }
```

#### It must contain valid zone data for your zone(s).

In the folder `etc/bind/zones` contains the normal zone and reverse zone.

They are configurated to be used in `etc/bind/named.conf.local`
```cpp
// Master zone
zone "g2.student.ida.liu.se" {
  type master;
  file "/etc/bind/zones/g2.student.ida.liu.se.db";

  // dnssec keys
  key-directory "/etc/bind/keys/g2.stduent.ida.liu.se";

  // publish and activate dnssec keys
  auto-dnssec maintain;

  // use inline signing
  inline-signing yes;
};

// Reversed zone
zone "2/24.0.0.10.in-addr.arpa." {
        type slave;
        file "/etc/bind/zones/10-24.0.0.10.in-addr.arpa";
        masters {
            student.ida.liu.se;
        };
};

```
#### The cache parameters must be chosen sensibly.

The motivation for the cache parameters for the zone is commented in the zone file:

`/etc/bind/zones/db.g2.student.ida.liu.se`

Furthermore in config `etc/bind/named.conf.options` we limit the cache-size
as we don't want it to be unlimited.
```json
max-cache-size 96M;
```

#### It must not be susceptible to the standard cache poisoning attacks.
* We limit recursive queries to trusted hosts.
* We use enable dnssec & dnssec-validation:
  ```
    dnssec-enable yes;
    dnssec-validation auto;
  ``` 
  Which enables a secure protocol thats protects against forged or manipulated
  DNS data. 

  The keys used for dnssec can be found in `etc/bind/keys`.
  We followed this [guide]("https://ftp.isc.org/isc/dnssec-guide/html/dnssec-guide.html#dnssec-signing") to generate the keys and setup inline-signing.
  
* We hide our BIND version
  ```
    version "Forbidden";
  ``` 
  To give as little information as possible to a potential intruder.
* Generally good cache parameters increase stability & security of our server


## NTP

### Network time

Gateway `etc/ntp.conf` -> NTP host
Clients `etc/ntp.conf` -> NTP clients

Vi försökte använda broadcast men det gick inte (varför?).
Använder unicast nu istället (standard). 

## NIS

### Install a simple directory service
[guide](https://likegeeks.com/linux-nis-server/)
#### Server
Instrallerade `ypserv`, `nis` på servern.

`ypinit -m` för att initialize servern (updatera alla standard entries).

#### Client
Instrallerade `ypbind`, `nis` på clients.

Starta `ypbind` och ändra `nsswitch.conf` att använda nis.

La till servern (`server.g2.student.ida.liu.se`) i hosts eftersom vår DNS inte
funkar.

Kontrolleras med `ypcat ${map name}` i en client. 

Kontrolleras med `ypwhich` i en client för domainnamn. 

## STO
Vi körde kommandot `lsblk` på vår server och såg att våra tillgängliga enheter var vda, vdb, vdc, vdd

### RAID
[guide](https://www.digitalocean.com/community/tutorials/how-to-create-raid-arrays-with-mdadm-on-ubuntu-16-04#creating-a-raid-1-array)

#### RAID 0
"4-1 Combine /dev/ubd2 and /dev/ubd3 into a RAID 0 set named /dev/md0"
`mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2 /dev/vda /dev/vdb`

"4-2 Create a file system on /dev/md0 and mount it on /mnt. How much space is there in the file system."
skapa filsystem
`mkfs.ext4 -F /dev/md0`
skapa mount point
`mkdir -p /mnt/md0`
mounta filsystem
`mount /dev/md0 /mnt/md0`

Filsystemet har 100Mb eftersom raid 0 adderar storleken från de två 50Mb devicesen.

#### RAID 1
5-1 Combine /dev/ubd2 and /dev/ubd3 into a RAID 1 set named /dev/md0.
`mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/vda /dev/vdb`

5-2 Create a file system on /dev/md0 and mount it on /mnt. How much space is there in the file system? Why.
skapa filsystem
`mkfs.ext4 -F /dev/md0`
skapa mount point
`mkdir -p /mnt/md0`
mounta filsystem
`mount /dev/md0 /mnt/md0`

Filsystemet har 50Mb eftersom raid 1 kopierar alla filer från den ena disken till den andra

5-3 Add /dev/ubd4 as a spare in /dev/md0, then fail /dev/ubd3 (using mdadm). What happens.
adda spare
`mdadm /dev/md0 --add /dev/vdc`
faila /dev/vdb
`mdadm /dev/md0 -fail /dev/vdb`
"What happens?"
vdc tar över vdb's plats

#### RAID 1+0
6-1 Combine /dev/ubd2, /dev/ubd3, /dev/ubd4, and /dev/ubd5 into a RAID 1+0 device named /dev/md0. You may need to create intermediate raid sets to do this.
`mdadm --create --verbose /dev/md0 --level=10 --raid-devices=3 /dev/vda /dev/vdb /dev/vdc`

6-2 Create an ext2 file system on /dev/md0 and mount it on mnt. How much space is there in the file system?
skapa filsystem
`sudo mkfs.ext4 -F /dev/md0`
skapa mount point
`mkdir -p /mnt/md0`
mounta filsystem
`mount /dev/md0 /mnt/md0`

Filsystemet har 50Mb

### LVM2
[guide](https://www.tecmint.com/manage-and-create-lvm-parition-using-vgcreate-lvcreate-and-lvextend/)
7-1 Create physical volumes on /dev/ubd2, /dev/ubd3, and /dev/ubd4.
`pvcreate /dev/vda /dev/vdb /dev/vdc`

Skapa grupp vg1
`vgcreate vg1 /dev/vda /dev/vdb /dev/vdc`

Skapa logical volumes lvol0 och lvol1 i gruppen
`lv create -n lvol0 -L 2M vg1`
`lv create -n lvol1 -L 2M vg1`

Skapa ext2 filsystem på lvol0 och lvol1
`mke2fs /dev/vg1/lvol0`
`mke2fs /dev/vg1/lvol1`

mounta filsystemen
`mount -t ext2 /dev/vg1/lvol0 /mnt/lv0`
`mount -t ext2 /dev/vg1/lvol1 /mnt/lv1`


### Putting it into practice

10-1 Use RAID 1 to create a device on which you place an ext2 file system optimized for many small files, that you mount as /home1 on the server. Make sure that /home1 is correctly mounted at boot.
`mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/vda /dev/vdb`

skapa filsystem
`mkfs.ext2 -F /dev/md0`
skapa mount point
`mkdir -p /home1`
mounta filsystem
`mount /dev/md0 /home1`

updatera `/etc/fstab` så att mounten överlever boot

`UUID="[Device UUID] /home1 ext2 defaults 0 0`


10-2 Use LVM to create a device on which you place an ext2 file system optimized for a smaller number of large files, that you mount as /home2 on the server. Make sure that /home2 is correctly mounted at boot.

`pvcreate /dev/vdc`
`vgcreate vg1 /dev/vdc`
`lv create -n lvolhome2 -l 100%FREE vg1`
`mke2fs /dev/vg1/lvolhome2`
`mkdir -p /home2`
`mount /dev/md0 /home2`

updatera `/etc/fstab` så att mounten överlever boot

`UUID="[Device UUID] /home2 ext2 defaults 0 0`



## NFS

### Network File System
Installera nfs-kernel server på servern
`apt-get install nfs-kernel-server`
Uppdatera /etc/exports på servern
`/usr/local 10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)`

Mounta /usr/local från servern på klienten
`mount -t nfs 10.0.0.2:/usr/local /usr/local`
Uppdatera klienternas `/etc/fstab` så det överlever reboot
`10.0.0.2:usr/local /usr/local nfs defaults 0 0`

### Preparations
4-3 Configure your NFS server to export /home1 and /home2 with the appropriate permissions to your clients (and only your clients).
Lägg till home1 och home2 i serverns `/etc/exports`
`
/home1 10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)
/home2 10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)
`

### The automounter
Installera autofs på båda klienterna och servern
`apt-get install autofs`

Uppdatera serverns auto.master fil med serverns mount point (/home) och en referens till auto.home
`
+dir:/etc/auto.master.d

/home /etc/auto.home --timeout=30
`

Uppdatera serverns auto.home fil med automount info
`
home1 -fstype=auto 10.0.0.2:/home1
home2 -fstype=auto 10.0.0.2:/home2
`

Lägg till auto.master och auto.home i /etc/var/yp/Makefile så att nis skickar ut dem
`ALL += auto.master auto.home`

Server klar

Uppdatera klienternas auto.master och auto.home så att de får sitt innehåll från nis
`+auto.master`
`+auto.home`

Lägg till automount i klienternas `nsswitch.conf`
`automount: files nis`

## Notes
