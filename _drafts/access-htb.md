---
title: access-htb
date: 2024-04-08 05:34:04 +0000
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
─# /home/blo/tools/nmapautomate/nmapauto.sh $ip

###############################################
###---------) Starting Quick Scan (---------###
###############################################

Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-04-08 05:35 GMT
Initiating Ping Scan at 05:35
Scanning 10.10.10.98 [4 ports]
Completed Ping Scan at 05:35, 0.23s elapsed (1 to
    Host is up (0.20s latency).
Not shown: 997 filtered tcp ports (no-response)
PORT   STATE SERVICE
21/tcp open  ftp
23/tcp open  telnet
80/tcp open  http

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 12.65 seconds
           Raw packets sent: 2008 (88.328KB) | Rcvd: 11 (468B)


----------------------------------------------------------------------------------------------------------
Open Ports : 21,23,80                                                                                                                                        
---------------------------------------
Host is up (0.25s latency).
Not shown: 65532 filtered tcp ports (no-response)
PORT   STATE SERVICE VERSION
21/tcp open  ftp     Microsoft ftpd
23/tcp open  telnet  Microsoft Windows XP telnetd
80/tcp open  http    Microsoft IIS httpd 7.5
Service Info: OSs: Windows, Windows XP; CPE: cpe:/o:microsoft:windows, cpe:/o:microsoft:windows_xp

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 96.82 seconds
           Raw packets sent: 131127 (5.770MB) | Rcvd: 148 (21.370KB)


```


- Port 80 je trouve `LON-MC6`

- second scan

```sh
─# nmap -sCV -Pn -p21,23,80 $ip     
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-04-08 05:38 GMT
Nmap scan report for 10.10.10.98
Host is up (0.23s latency).

PORT   STATE SERVICE VERSION
21/tcp open  ftp     Microsoft ftpd
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
|_Can't get directory listing: TIMEOUT
| ftp-syst: 
|_  SYST: Windows_NT
23/tcp open  telnet  Microsoft Windows XP telnetd
| telnet-ntlm-info: 
|   Target_Name: ACCESS
|   NetBIOS_Domain_Name: ACCESS
|   NetBIOS_Computer_Name: ACCESS
|   DNS_Domain_Name: ACCESS
|   DNS_Computer_Name: ACCESS
|_  Product_Version: 6.1.7600
80/tcp open  http    Microsoft IIS httpd 7.5
| http-methods: 
|_  Potentially risky methods: TRACE
|_http-server-header: Microsoft-IIS/7.5
|_http-title: MegaCorp
Service Info: OSs: Windows, Windows XP; CPE: cpe:/o:microsoft:windows, cpe:/o:microsoft:windows_xp

Host script results:
|_clock-skew: -2s
```


```sh
─# ftp $ip 21   
Connected to 10.10.10.98.
220 Microsoft FTP Service
Name (10.10.10.98:blo): ftp
331 Anonymous access allowed, send identity (e-mail name) as password.
Password: 
230 User logged in.
Remote system type is Windows_NT.
ftp> 

```



## Privilege Escalation






## Ressources supplementaires
Voici quelques ressources supplémentaires qui pourraient vous être utiles :
[]()
[]()
- [Join Us on Discord](https://discord.gg/wBT9wr9ruG).
