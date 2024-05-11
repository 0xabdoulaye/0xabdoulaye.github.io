---
title: Hacking for Beginners - Bandit Levels 14-16 on OverTheWire
date: 2023-11-04 00:00:00 -500
categories: [OverTheWire]
tags: [Bandit, Linux, CTFs, Hacking]
image:
    path: https://i.ibb.co/8MJXs9H/banditcover.png
---

Welcome back Hackers, **to The Hacking Journey**, In our previous series of Bandit challenges on OvertheWire, we embarked on an exciting **Hacking Journey** through the Bandit wargame by OverTheWire, specifically focusing on Bandit levels 11 to 13. If you missed those adventures, don't worry; you can catch up on all the action and insights [here](https://blackcybersec.xyz/categories/overthewire/).

If you're eager to enhance your hacking skills and learn alongside us, we invite you to join the ranks of aspiring hackers and cybersecurity enthusiasts.

- **The Best Academy to Learn Hacking is [Here](https://affiliate.hackthebox.com/nenandjabhata)**.
- **Beginner Friendly challenges on TryHackMe [Here](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.

## **Level 14**: SSH using private key.

- **GOAL**: 
The password for the next level is stored in `/etc/bandit_pass/bandit14` and can only be read by user `bandit14`. For this level, you don’t get the next password, but you get a private SSH key that can be used to log into the next level. Note: localhost is a hostname that refers to the machine you are working on

- **SOLUTION**:
To tackle this level, we begin by utilizing the password we obtained from the previous Bandit level, `bandit13`. Let's first connect to the `bandit13` user account:
```terminal
bandit13@bandit:~$ ls
sshkey.private
bandit13@bandit:~$ file sshkey.private 
sshkey.private: PEM RSA private key
bandit13@bandit:~$ 
```
As you can see, we successfully access the `bandit13` user account and discover a file labeled as a `PEM RSA private key`. This private key can be employed to log in to the `bandit14` user's SSH account without the need for a password.

```terminal
bandit13@bandit:~$ ssh -i sshkey.private bandit14@localhost -p 2220
The authenticity of host '[localhost]:2220 ([127.0.0.1]:2220)' can't be established.
ED25519 key fingerprint is SHA256:C2ihUBV7ihnV1wUXRb4RrEcLfXC5CXlhmAAM/urerLY.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Could not create directory '/home/bandit13/.ssh' (Permission denied).
Failed to add the host to the list of known hosts (/home/bandit13/.ssh/known_hosts).

  For more information regarding individual wargames, visit
  http://www.overthewire.org/wargames/

  For support, questions or comments, contact us on discord or IRC.

  Enjoy your stay!

bandit14@bandit:~$ whoami
bandit14
```
Now here i used `ssh` command using the `-i` flag to specify the private key, also the `-p` 2220 to specify the port.
As we can see, the `whoami` command confirms that we are now logged in as `bandit14`.

```terminal
bandit14@bandit:~$ cat /etc/bandit_pass/bandit14
fGrHPx402xGC7U7rXKDaxiWFTOiF0ENq
bandit14@bandit:~$ 
```

## **Level 15**: Submit password using Telnet.

- **GOAL**: 
The password for the next level can be retrieved by submitting the password of the current level to port `30000` on localhost.

- **SOLUTION**:
To solve this level we will use a tool called `telnet` to connect on the port `30000` and then submit the current level password.
To do that, i am connected on the user `bandit14`.
```terminal
bandit14@bandit:~$ telnet localhost 30000
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.

```
OK now all we have to do is to submit the password.
```terminal
Escape character is '^]'.
fGrHPx402xGC7U7rXKDaxiWFTOiF0ENq
Correct!
jN2kgmIXJ6fShzhT2avhotn4Zcka6tnt

Connection closed by foreign host.

```
As we can see, when i submited the password i got my next level password. The chall has been solved.


### Join Us
Thanks for reading. **Let's learn, explore, and hack together**. **Join us on Discord [here](https://discord.gg/wBT9wr9ruG)**. 