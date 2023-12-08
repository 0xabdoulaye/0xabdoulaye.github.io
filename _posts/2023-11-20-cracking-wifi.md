---
title: Cracking WiFi Passwords - Hashcat Master
date: 2023-11-20 00:00:00 -500
categories: [Hacking for Beginners, CTFs]
tags: [Hashcat, HTB, Easy, Hacking]
image:
    path: https://i.ibb.co/8M8cxV7/wifi-crack.jpg
---

Imagine You are conducting a WIFI pentest, Handshake has been captured and your task is to crack it.  In this blog, I'll guide you through the process of cracking a WiFi handshake password using the powerful tool known as `Hashcat` Learn the ropes of ethical hacking and elevate your skills to become a **Hashcat Master**.

- **The Best Academy to Learn Hacking is [Here](https://affiliate.hackthebox.com/nenandjabhata)**.
- **Beginner Friendly challenges on TryHackMe [Here](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.

## WPA Crack Challenge.
**Description :**
You are conducting a WIFI pentest, Handshake has been captured and your task is to crack it
- Flag format is just the password 

First we will Download the challenge file in this [Link](https://hubchallenges.s3-eu-west-1.amazonaws.com/Machines/wpa943050264305852656243865.cap)


## Solution
To solve this challenge we need a first tool called `hcxpcapngtool`. it's a tool that help US to convert a `.cap` into `hashcat` crackable format.
- To install it on Linux follow this : https://www.kali.org/tools/hcxtools/

```terminal
└─# hcxpcapngtool -o hashwifi.txt -E essidlist wpa943050264305852656243865.cap 
hcxpcapngtool 6.2.7 reading from wpa943050264305852656243865.cap...
```
Here is what i did:
- -o : get full advantage of reuse of PBKDF2 on PMKID and EAPOL
- -E : To  retrieved from every frame that contain an ESSID

```terminal
└─# cat hashwifi.txt 
WPA*02*cc303dcc8fb0b285257353480a52c563*000d93ebb08c*00095b91535d*74657374*54adc644966dc8423d44364a1de9ec22415522bd0555ee718f8a53b8d679470c*0103005ffe010900200000000000000001fe5f0c5b5423815f35fe606720bbb9466d8601a8b4493af4cf5a0317f38c83870000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000*05
```
In our output file named `hashwifi.txt` we have an WPA-PBKDF2-PMKID+EAPOL hash file for hashcat we use `-m 22000`.
- Hashcat Examples : https://hashcat.net/wiki/doku.php?id=example_hashes

**Cracking the Hash with RockYou**
```terminal
└─# hashcat -m 22000 hashwifi.txt -a 0 /usr/share/wordlists/rockyou.txt       
hashcat (v6.2.6) starting

OpenCL API (OpenCL 3.0 PoCL 3.0+debian  Linux, None+Asserts, RELOC, LLVM 13.0.1, SLEEF, DISTRO, POCL_DEBUG) - Platform #1 [The pocl project]
============================================================================================================================================
* Device #1: pthread-Intel(R) Core(TM) i5-3427U CPU @ 1.80GHz, 1389/2843 MB (512 MB allocatable), 4MCU

Minimum password length supported by kernel: 8
Maximum password length supported by kernel: 63

cc303dcc8fb0b285257353480a52c563:000d93ebb08c:00095b91535d:test:XXXXXX
                                                          
Session..........: hashcat
Status...........: Cracked
Hash.Mode........: 22000 (WPA-PBKDF2-PMKID+EAPOL)
Hash.Target......: hashwifi.txt
Time.Started.....: Sun Nov 19 17:55:10 2023 (29 secs)
Time.Estimated...: Sun Nov 19 17:55:39 2023 (0 secs)
Kernel.Feature...: Pure Kernel
Guess.Base.......: File (/usr/share/wordlists/rockyou.txt)
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:     2022 H/s (7.38ms) @ Accel:64 Loops:256 Thr:1 Vec:8
Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)
Progress.........: 151377/14344385 (1.06%)
Rejected.........: 93777/151377 (61.95%)
Restore.Point....: 150811/14344385 (1.05%)
Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:0-1
Candidate.Engine.: Device Generator
Candidates.#1....: carpediem1 -> bangonthedoor
Hardware.Mon.#1..: Temp: 87c Util: 96%

Started: Sun Nov 19 17:55:01 2023
Stopped: Sun Nov 19 17:55:41 2023
```
As you can see here now, the hash has been cracked. Very Easy right ?

Thanks for reading.
### Join Us
Thanks for reading. **Let's learn, explore, and hack together**. **Join us on Discord [here](https://discord.gg/wBT9wr9ruG)**. 
