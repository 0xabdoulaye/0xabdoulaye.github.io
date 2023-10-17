---
title: Windows Hacking for Beginners - The Dancing Box
date: 2023-10-18 00:00:00 -500
categories: [Hacking for Beginners, Boot2root CTFs]
tags: [CTFs, HTB, Easy, Hacking]
image:
    path: https://i.ibb.co/tzxvvNV/dancing-HTB.jpg
---
Hello Everyone, In this blog, I will guide you through the steps to solve the ***Dancing*** machine, part of the **Starting Point** labs on HacktheBox. This machine has been classified `Free` and **Very Easy** making it an ideal choice for beginners looking to embark on their journey into the exciting world of ethical hacking.
If you're eager to enhance your hacking skills and learn alongside us, we invite you to join the ranks of aspiring hackers and cybersecurity enthusiasts.
**Exploit the Lab [Here](https://affiliate.hackthebox.com/nenandjabhata)**.
**Join TryHackMe [Here](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.

## Enumeration(Recon)

**First Basic Scan**
```terminal
└─# nmap 10.129.67.178               
PORT    STATE SERVICE
135/tcp open  msrpc
139/tcp open  netbios-ssn
445/tcp open  microsoft-ds

Nmap done: 1 IP address (1 host up) scanned in 35.64 seconds
```
In this initial step of enumeration, we employ the Nmap tool to scan the target machine, which is identified by the IP address `10.129.67.178`. The purpose of this scan is to discover open ports and services running on the target system.

**Second Scan**
In the second scan, we will use Nmap with version detection (`-sV`) and default scripts (`-sC`) to gather more information about the target.
```terminal
└─# nmap -sV -sC -Pn -p135,139,445 10.129.67.178
PORT    STATE SERVICE       VERSION
135/tcp open  msrpc         Microsoft Windows RPC
139/tcp open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp open  microsoft-ds?
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
|_clock-skew: 4h04m50s
| smb2-security-mode: 
|   311: 
|_    Message signing enabled but not required
| smb2-time: 
|   date: 2023-10-18T01:05:10
|_  start_date: N/A
```
 - The results show detailed service information for the open ports (135/tcp, 139/tcp, and 445/tcp), including their corresponding Windows services. This scan serves as a more comprehensive examination of the target's services, aiding in vulnerability assessment.

Here we found `SMB` port 139 and 445. for more about smb Hacking look at this : [Hacktricks](https://book.hacktricks.xyz/network-services-pentesting/pentesting-smb).

**Enumerating Shares with smbclient**
Using the `smbclient` tool with the `-L` flag and the specified IP address, we perform a share enumeration on the target system.
```terminal
└─# smbclient -L $ip
Password for [WORKGROUP\bloman]:

	Sharename       Type      Comment
	---------       ----      -------
	ADMIN$          Disk      Remote Admin
	C$              Disk      Default share
	IPC$            IPC       Remote IPC
	WorkShares      Disk  
```
After providing the requested password, the command returns a list of accessible shares:

   - `ADMIN$`: This is a disk share used for remote administration.
   - `C$`: It's a disk share representing the default administrative share.
   - `IPC$`: This is an Inter-Process Communication share for remote IPC.
   - `WorkShares`: A disk share that may contain additional resources or information relevant to the system.

## Foothold
Let's try to connect on every share available, i begin with `ADMIN$`
```terminal
└─# smbclient  \\\\10.129.67.178\\ADMIN$    
Password for [WORKGROUP\bloman]:
tree connect failed: NT_STATUS_ACCESS_DENIED
```
This outcome suggests that access to the `ADMIN$` share is currently denied or restricted, which is a common security measure in Windows environments. Our next steps will involve further exploration to identify accessible shares.

Let's move on to the share `C$`
```terminal
└─# smbclient  \\\\10.129.67.178\\C$
Password for [WORKGROUP\bloman]:
tree connect failed: NT_STATUS_ACCESS_DENIED
```
Same output. Let's move to WorkShares.
```terminal
└─# smbclient  \\\\10.129.67.178\\WorkShares
Password for [WORKGROUP\bloman]:
Try "help" to get a list of possible commands.
```
Upon moving to the `WorkShares share`, we successfully establish a connection.
```terminal
smb: \> ls
  .                                   D        0  Mon Mar 29 08:22:01 2021
  ..                                  D        0  Mon Mar 29 08:22:01 2021
  Amy.J                               D        0  Mon Mar 29 09:08:24 2021
  James.P                             D        0  Thu Jun  3 08:38:03 2021
cd 
		5114111 blocks of size 4096. 1747687 blocks available
smb: \> cd James.P
smb: \James.P\> ls
  .                                   D        0  Thu Jun  3 08:38:03 2021
  ..                                  D        0  Thu Jun  3 08:38:03 2021
  flag.txt                            A       32  Mon Mar 29 09:26:57 2021

```
we can list the contents of the share. The share contains subdirectories, and we navigate to the `James.P` directory.
```terminal
smb: \James.P\> get flag.txt
getting file \James.P\flag.txt of size 32 as flag.txt (0.0 KiloBytes/sec) (average 0.0 KiloBytes/sec)
smb: \James.P\> 
```
In the `James.P` directory, we find a file named `flag.txt` last modified on March 29, 2021. This discovery is significant as it could potentially lead to gaining access to sensitive information or serve as an entry point for further exploitation and privilege escalation on the target system. The presence of `flag.txt` piques our interest, and we proceed to examine its contents.
### Join Us
Thanks for reading. **Let's learn, explore, and hack together**. **Join us on Discord [here](https://discord.gg/wBT9wr9ruG)**. 
