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

### RAID

### LVM2

### Putting it into practice

## NFS

### Network File System

### The automounter

## Notes
